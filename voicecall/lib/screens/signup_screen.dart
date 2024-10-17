import 'package:flutter/material.dart';
import '../widgets/customized_button.dart';
import '../widgets/customized_textfield.dart';
import '../widgets/loading_spinner.dart'; // Import loading spinner
import 'login_screen.dart';
import '../services/auth_methods.dart';
import '../services/firestore_methods.dart';
import 'package:voicecall/models/user.dart'; // Your User model

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthMethods _authMethods = AuthMethods();
  bool _isLoading = false; // State for loading spinner

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
                    colors: [Color.fromARGB(255, 11, 204, 165), Color.fromARGB(255, 10, 175, 246)],
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
                      const SizedBox(height: 10),

                      // Title
                      const Text(
                        "Hello! Register to get Started",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Full Name Text Field
                      CustomizedTextfield(
                        myController: _fullNameController,
                        hintText: "Full Name",
                        isPassword: false,
                      ),

                      // Email Address Text Field
                      CustomizedTextfield(
                        myController: _emailController,
                        hintText: "Email Address",
                        isPassword: false,
                      ),

                      // Password Text Field
                      CustomizedTextfield(
                        myController: _passwordController,
                        hintText: "Password",
                        isPassword: true,
                        keyboardType: TextInputType.visiblePassword,
                      ),

                      // Phone Number Text Field
                      CustomizedTextfield(
                        myController: _phoneNumberController,
                        hintText: "Phone Number",
                        isPassword: false,
                        keyboardType: TextInputType.phone,
                      ),

                      // Birthday Text Field with Date Picker
                      GestureDetector(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _birthdayController.text =
                                  "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: CustomizedTextfield(
                            myController: _birthdayController,
                            hintText: "Birthday (DD/MM/YYYY)",
                            isPassword: false,
                          ),
                        ),
                      ),

                      // Location Text Field
                      CustomizedTextfield(
                        myController: _locationController,
                        hintText: "Location",
                        isPassword: false,
                      ),

                      const SizedBox(height: 5),

                      // Register Button with Firebase Integration
                      Center(
                        child: _isLoading
                            ? const CircularProgressIndicator() // Show loading spinner while registering
                            : CustomizedButton(
                                buttonText: "Register",
                                buttonColor: const Color(0xFFEC407A), // Pink button
                                textColor: Colors.white,
                                borderRadius: 25,
                                onPressed: () async {
                                  setState(() {
                                    _isLoading = true; // Start loading
                                  });

                                  String result = await _authMethods.signUpUser(
                                    fullName: _fullNameController.text,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    phoneNumber: _phoneNumberController.text,
                                    birthday: _birthdayController.text,
                                    location: _locationController.text,
                                  );

                                  setState(() {
                                    _isLoading = false; // Stop loading
                                  });

                                  if (result == "success") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const LoginScreen()),
                                    );
                                  } else {
                                    _showErrorDialog(result); // Show error dialog on failure
                                  }
                                },
                              ),
                      ),

                      const SizedBox(height: 5),

                      // Already have an account? Login Now
                      Center(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          },
                          child: RichText(
                            text: const TextSpan(
                              text: "Already have an account? ", // Regular style
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                              ),
                              children: [
                                TextSpan(
                                  text: "Login Now", // Bold and different color
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 21, 255), // Different color
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

  // Error dialog method
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
}
