import 'package:flutter/material.dart';
import 'package:voicecall/screens/login_screen.dart';
import 'package:voicecall/screens/signup_screen.dart';
import 'package:voicecall/widgets/customized_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Defining constants for colors to maintain consistency
  static const Color primaryColor = Color.fromARGB(255, 69, 208, 239);
  static const Color buttonTextColor = Color(0xFF007BFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        color: primaryColor,
        child: SingleChildScrollView(  // Enables scrolling for smaller screens
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80), // Spacing from the top

              // App name and tagline section
              const Text(
                "Voice Call Translator",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10), // Small spacing between title and tagline
              const Text(
                "Break the language barrier",
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40), // Space before the image

              // Image section with placeholder handling
              SizedBox(
                height: 250,
                width: 300,
                child: Image.asset(
                  "assets/icon.png",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.white70,
                    );
                  },
                ),
              ),

              const SizedBox(height: 40), // Extra spacing before buttons

              // Login button
              CustomizedButton(
                buttonText: "Login",
                buttonColor: Colors.black,
                textColor: Colors.white,
                borderRadius: 25,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),

              const SizedBox(height: 20), // Spacing between buttons

              // Register button
              CustomizedButton(
                buttonText: "Register",
                buttonColor: Colors.white,
                textColor: buttonTextColor,
                borderRadius: 25,
                borderColor: buttonTextColor,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                  );
                },
              ),

              const SizedBox(height: 80), // Bottom spacing for a clean look
            ],
          ),
        ),
      ),
    );
  }
}
