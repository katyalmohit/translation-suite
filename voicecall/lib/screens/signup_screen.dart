import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voicecall/screens/recent_screen.dart';
import '../widgets/customized_button.dart';
import '../widgets/customized_textfield.dart';
import '../widgets/loading_spinner.dart';
import 'login_screen.dart';
import '../services/auth_methods.dart';
import '../services/firestore_methods.dart';
import 'package:voicecall/models/user.dart' as AppUserModel;

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
  final FirestoreMethods _firestoreMethods = FirestoreMethods();
  bool _isLoading = false;

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
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Hello! Register to get Started",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),

                      CustomizedTextfield(
                        myController: _fullNameController,
                        hintText: "Full Name",
                        isPassword: false,
                      ),

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

                      CustomizedTextfield(
                        myController: _phoneNumberController,
                        hintText: "Phone Number",
                        isPassword: false,
                        keyboardType: TextInputType.phone,
                      ),

                      GestureDetector(
                        onTap: _pickDate,
                        child: AbsorbPointer(
                          child: CustomizedTextfield(
                            myController: _birthdayController,
                            hintText: "Birthday (DD/MM/YYYY)",
                            isPassword: false,
                          ),
                        ),
                      ),

                      CustomizedTextfield(
                        myController: _locationController,
                        hintText: "Location",
                        isPassword: false,
                      ),

                      const SizedBox(height: 5),
                      Center(
                        child: _isLoading
                            ? const LoadingSpinner()
                            : CustomizedButton(
                                buttonText: "Register",
                                buttonColor: const Color(0xFFEC407A),
                                textColor: Colors.white,
                                borderRadius: 25,
                                onPressed: _registerUser,
                              ),
                      ),
                      const SizedBox(height: 5),
                      Center(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                            );
                          },
                          child: RichText(
                            text: const TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                              ),
                              children: [
                                TextSpan(
                                  text: "Login Now",
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

Future<void> _registerUser() async {
  String fullName = _fullNameController.text.trim();
  String email = _emailController.text.trim();
  String phoneNumber = _phoneNumberController.text.trim();
  String birthday = _birthdayController.text.trim();
  String location = _locationController.text.trim();
  String password = _passwordController.text.trim();

  if (fullName.isEmpty ||
      email.isEmpty ||
      password.isEmpty ||
      phoneNumber.isEmpty ||
      birthday.isEmpty ||
      location.isEmpty) {
    _showErrorDialog("Please fill out all fields.");
    return;
  }

  setState(() => _isLoading = true); // Start loading spinner

  try {
    // Register the user with Firebase Authentication
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    User? user = userCredential.user;

    if (user != null) {
      // Save user data to Firestore
      await _firestoreMethods.saveUserData(
        AppUserModel.User(
          uid: user.uid,
          fullName: fullName,
          email: email,
          phoneNumber: phoneNumber,
          birthday: birthday,
          location: location,
        ),
      );

      // Send the email verification
      await user.sendEmailVerification();

      // Give Firebase some time to update the user state
      await Future.delayed(const Duration(seconds: 2));

      // Reload the user to confirm the state
      await user.reload();
      user = FirebaseAuth.instance.currentUser;

      // Show a success dialog to the user
      _showInfoDialog("Verification email sent! Please check your inbox.");

      // Uncomment this after testing if needed
      // await FirebaseAuth.instance.signOut();
    }
  } on FirebaseAuthException catch (e) {
    _showErrorDialog(e.message ?? "Registration failed. Please try again.");
  } catch (e) {
    _showErrorDialog("An unknown error occurred.");
  } finally {
    setState(() => _isLoading = false); // Stop loading spinner
  }
}


// Display a dialog with a message
void _showInfoDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Info"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

  Future<void> _pickDate() async {
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

}
