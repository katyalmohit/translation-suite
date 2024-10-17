import 'package:voicecall/screens/login_screen.dart';
import 'package:voicecall/screens/signup_screen.dart';
import 'package:voicecall/widgets/customized_button.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        color: const Color.fromARGB(255, 69, 208, 239),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100), // Spacing from the top
            
            // App name and tagline section
            const Text(
              "Voice Call Translator",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10), // Small spacing between title and tagline
            const Text(
              "Break the language barrier",
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: Colors.black87,
              ),
            ),

            // Image placed between tagline and buttons
            const SizedBox(height: 40), // Space before the image
            const SizedBox(
              height: 250,
              width: 300,
              child: Image(
                image: AssetImage("assets/icon.png"), // Insert your logo image here
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 40), // Extra spacing before buttons

            // Login button
            CustomizedButton(
              buttonText: "Login",
              buttonColor: const Color.fromARGB(255, 0, 0, 0), // Matching blue with logo
              textColor: Colors.white,
              borderRadius: 25,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
            ),

            const SizedBox(height: 20), // Spacing between buttons

            // Register button
            CustomizedButton(
              buttonText: "Register",
              buttonColor: Colors.white,
              textColor: const Color(0xFF007BFF), // Matching blue text
              borderRadius: 25,
              borderColor: const Color(0xFF007BFF), // Adding border
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen()));
              },
            ),

            const SizedBox(height: 80), // Bottom spacing for a clean look
          ],
        ),
      ),
    );
  }
}
