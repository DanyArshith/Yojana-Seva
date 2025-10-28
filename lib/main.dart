import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:yojana_seva/providers/auth_provider.dart';
import 'package:yojana_seva/providers/scheme_provider.dart';
import 'package:yojana_seva/screens/auth_screen.dart';
import 'package:yojana_seva/screens/main_navigation.dart';
import 'package:yojana_seva/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SchemeProvider()),
      ],
      child: MaterialApp(
        title: 'Yojana Seva',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF1E88E5),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: const Color(0xFFFBC02D),
          ),
          scaffoldBackgroundColor: Colors.grey[50],
          fontFamily: 'Roboto',
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
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E88E5),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.user != null) {
          return const MainNavigation();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}
