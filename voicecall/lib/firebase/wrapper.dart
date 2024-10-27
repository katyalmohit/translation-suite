import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voicecall/layout/mobile_layout.dart';
import 'package:voicecall/layout/web_layout.dart';
import 'package:voicecall/screens/login_screen.dart';
import 'package:voicecall/screens/welcome_screen.dart';

import '../layout/layout_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading spinner while waiting for auth state
          return const Center(
            child: CircularProgressIndicator(),
          );
        // } else if (snapshot.hasData && snapshot.data!.emailVerified) {
        } else if (snapshot.hasData) {
         // User is logged in and email is verified
          return const ResponsiveLayout(
            mobileScreenLayout: MobileScreenLayout(),
            webScreenLayout: WebScreenLayout(),
          );
        } else if (snapshot.hasData) {
          // User is logged in but email not verified, logout the user
          FirebaseAuth.instance.signOut(); // Automatically log out
          return const LoginScreen(); // Redirect to login screen
        } else {
          // No user is logged in, show WelcomeScreen
          return const WelcomeScreen();
        }
      },
    );
  }
}
