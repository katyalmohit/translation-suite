import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voicecall/firebase/wrapper.dart';
import 'package:voicecall/screens/otp_screen.dart'; 
import 'signup_screen.dart'; 
import 'forgot_password_screen.dart'; 
import '../widgets/customized_button.dart';
import '../widgets/customized_textfield.dart';
import '../widgets/loading_spinner.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      await user?.reload();
      user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool isPhoneVerified = prefs.getBool('isPhoneVerified') ?? false;

        if (!user.emailVerified) {
          _showVerificationDialog(user, type: "email");
        } else if (!isPhoneVerified) {
          _showVerificationDialog(user, type: "phone");
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Wrapper()),
          );
        }
      }
    } catch (e) {
      _showErrorDialog("An unknown error occurred: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showVerificationDialog(User user, {required String type}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${type == "email" ? "Email" : "Phone"} Not Verified'),
        content: Text('Please verify your $type to continue.'),
        actions: [
          if (type == "email")
            TextButton(
              onPressed: () async {
                await user.sendEmailVerification();
                _showInfoDialog("Verification email resent. Please check your inbox.");
              },
              child: const Text('Resend Email'),
            ),
          if (type == "phone")
            TextButton(
              onPressed: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OtpScreen(
                      verificationId: user.phoneNumber ?? "",
                    ),
                  ),
                );
              },
              child: const Text('Verify Phone'),
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
                      CustomizedTextfield(
                        myController: _emailController,
                        hintText: "Email Address",
                        isPassword: false,
                      ),
                      CustomizedTextfield(
                        myController: _passwordController,
                        hintText: "Password",
                        isPassword: true,
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Color.fromARGB(255, 33, 34, 33),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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
