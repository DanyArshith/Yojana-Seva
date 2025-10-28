import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yojana_seva/models/user_data.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserData? _userData;

  UserData? get userData => _userData;

  Future<void> createUser(UserData userData) async {
    try {
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception('No authenticated user');
      }
      await _firestore.collection('users').doc(uid).set(userData.toMap());
      _userData = userData;
      notifyListeners();
    } catch (e) {
      // Handle Firestore errors
      print(e);
    }
  }

  Future<void> getUser(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      _userData = UserData.fromMap(doc.data() as Map<String, dynamic>);
      notifyListeners();
    } catch (e) {
      // Handle Firestore errors
      print(e);
    }
  }

  Future<void> updateUser(UserData userData) async {
    try {
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception('No authenticated user');
      }
      await _firestore.collection('users').doc(uid).update(userData.toMap());
      _userData = userData;
      notifyListeners();
    } catch (e) {
      // Handle Firestore errors
      print(e);
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      _userData = null;
      notifyListeners();
    } catch (e) {
      // Handle Firestore errors
      print(e);
    }
  }
}
