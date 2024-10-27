import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voicecall/firebase/wrapper.dart';
import '../widgets/customized_button.dart';
import '../widgets/customized_textfield.dart';
import '../widgets/loading_spinner.dart';
import 'recent_screen.dart'; // Adjust if needed
import 'signup_screen.dart'; // To navigate to signup screen
import '../services/auth_methods.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthMethods _authMethods = AuthMethods();
  bool _isLoading = false;

  Future<void> _loginUser() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog("Please enter both email and password.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authMethods = AuthMethods();
      final result = await authMethods.login(email, password);

      if (result == null) {
        User? user = FirebaseAuth.instance.currentUser;

        // Reload user to ensure the latest state is fetched
        await user?.reload();
        user = FirebaseAuth.instance.currentUser;

        if (user != null && !user.emailVerified) {
          // Show a dialog to prompt for verification
          _showVerificationDialog(user);
        } else if (user != null && user.emailVerified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Wrapper()),
          );
        }
      } else {
        _showErrorDialog(result); // Show Firebase error message
      }
    } catch (e) {
      _showErrorDialog("An unknown error occurred.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showVerificationDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Not Verified'),
        content: const Text('Please verify your email to continue.'),
        actions: [
          TextButton(
            onPressed: () async {
              await user.sendEmailVerification();
              _showInfoDialog("Verification email resent. Please check your inbox.");
            },
            child: const Text('Resend Email'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _forgotPassword() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      _showErrorDialog("Please enter your email to reset your password.");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showInfoDialog("Password reset email sent. Please check your inbox.");
    } catch (e) {
      _showErrorDialog("An error occurred while sending reset email. Please try again.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
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

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Info"),
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 11, 204, 165),
                      Color.fromARGB(255, 10, 175, 246),
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
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Welcome Back! Glad to see you again!",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Email TextField
                      CustomizedTextfield(
                        myController: _emailController,
                        hintText: "Email Address",
                        isPassword: false,
                      ),

                      // Password TextField
                      CustomizedTextfield(
                        myController: _passwordController,
                        hintText: "Password",
                        isPassword: true,
                        keyboardType: TextInputType.visiblePassword,
                      ),

                      // Forgot Password Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _forgotPassword,
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Color.fromARGB(255, 33, 34, 33),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),


                      // Login Button with Loading Spinner
                      Center(
                        child: _isLoading
                            ? const LoadingSpinner()
                            : CustomizedButton(
                                buttonText: "Login",
                                buttonColor: const Color(0xFFEC407A),
                                textColor: Colors.white,
                                borderRadius: 25,
                                onPressed: _loginUser,
                              ),
                      ),
                      const SizedBox(height: 10),

                      // Don't have an account? Sign Up Now
                      Center(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: RichText(
                            text: const TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                              ),
                              children: [
                                TextSpan(
                                  text: "Register Now",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 21, 255),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
