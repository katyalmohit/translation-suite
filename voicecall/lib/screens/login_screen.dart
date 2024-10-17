import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:voicecall/screens/recent_screen.dart';
import 'package:voicecall/screens/signup_screen.dart';
import 'package:voicecall/widgets/customized_textfield.dart';
import '../services/firebase_auth_service.dart';
import '../widgets/customized_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 11, 204, 165),
                  Color.fromARGB(255, 10, 175, 246)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Welcome Back Title
                  const Text(
                    "Welcome Back! Glad to see you again",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Email Text Field
                  CustomizedTextfield(
                    myController: _emailController,
                    hintText: "Enter your Email",
                    isPassword: false,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  // Password Text Field
                  CustomizedTextfield(
                    myController: _passwordController,
                    hintText: "Enter your Password",
                    isPassword: true,
                  ),

                  const SizedBox(height: 20),

                  // Login Button with Firebase Authentication Logic
                  Center(
                    child: _isLoading
                        ? const CircularProgressIndicator() // Show loading spinner while logging in
                        : CustomizedButton(
                            buttonText: "Login",
                            buttonColor: const Color(0xFFEC407A), // Button color
                            textColor: Colors.white,
                            borderRadius: 25,
                            onPressed: () async {
                              setState(() {
                                _isLoading = true; // Show loading spinner
                              });

                              try {
                                // Firebase Authentication: Login user with email and password
                                String? errorMessage = await FirebaseAuthService().login(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );

                                setState(() {
                                  _isLoading = false; // Hide loading spinner
                                });

                                if (errorMessage == null) {
                                  // If no error, navigate to RecentScreen
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const RecentScreen()),
                                  );
                                } else {
                                  // Show error dialog if login fails
                                  _showErrorDialog(errorMessage);
                                }
                              } catch (e) {
                                setState(() {
                                  _isLoading = false; // Hide loading spinner on error
                                });
                                // Handle any unexpected errors
                                _showErrorDialog("An unexpected error occurred. Please try again.");
                              }
                            },
                          ),
                  ),

                  const SizedBox(height: 40),

                  // Don't have an account? Register Now
                  Center(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpScreen()),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: "Don't have an account? ", // Regular text style
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                          ),
                          children: [
                            TextSpan(
                              text: "Register Now", // Bold and different color for "Register Now"
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 21, 255), // Custom color
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Error dialog method
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Login Failed"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
