import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yojana_seva/models/user_data.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  UserData? _userData;
  bool _isLoading = false;

  User? get user => _user;
  UserData? get userData => _userData;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserData();
      } else {
        _userData = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData() async {
    if (_user == null) return;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_user!.uid)
          .collection('profile')
          .doc('userDetails')
          .get();

      if (doc.exists) {
        _userData = UserData.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;
      await _loadUserData();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (e) {
      return 'An unexpected error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;

      // Create empty user profile
      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .collection('profile')
          .doc('userDetails')
          .set({
        'detailsSubmitted': false,
      });

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (e) {
      return 'An unexpected error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return null; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      _user = userCredential.user;

      // Check if this is a new user
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        // Create empty user profile for new users
        await _firestore
            .collection('users')
            .doc(_user!.uid)
            .collection('profile')
            .doc('userDetails')
            .set({
          'detailsSubmitted': false,
        });
      }

      await _loadUserData();
      return null; // Success
    } catch (e) {
      return 'Google sign-in failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _user = null;
      _userData = null;
    } catch (e) {
      print('Error signing out: $e');
    }
    notifyListeners();
  }

  Future<void> saveUserData(UserData userData) async {
    if (_user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .collection('profile')
          .doc('userDetails')
          .set(userData.toMap());

      _userData = userData;
      notifyListeners();
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
