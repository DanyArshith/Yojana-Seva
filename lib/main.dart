import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:yojana_seva/providers/auth_provider.dart';
import 'package:yojana_seva/providers/user_provider.dart';
import 'package:yojana_seva/screens/my_details_screen.dart';
import 'package:yojana_seva/screens/success_screen.dart';
import 'package:yojana_seva/screens/user_details_screen.dart';
import 'package:yojana_seva/screens/verification_screen.dart';
import 'package:yojana_seva/screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Yojana Seva',
        theme: ThemeData(
          primaryColor: const Color(0xFF1E88E5),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: const Color(0xFFFBC02D),
          ),
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Poppins',
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Color(0xFF212121)),
            bodySmall: TextStyle(color: Color(0xFF616161)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 2,
              padding: const EdgeInsets.all(16.0),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Color(0xFF1E88E5),
              ),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomeScreen(),
          '/verification': (context) => const VerificationScreen(),
          '/registration': (context) => const UserDetailsScreen(),
          '/success': (context) => const SuccessScreen(),
          '/my_details': (context) => const MyDetailsScreen(),
        },
      ),
    );
  }
}
