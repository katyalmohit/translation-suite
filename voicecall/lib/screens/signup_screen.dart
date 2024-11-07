import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voicecall/screens/otp_screen.dart';
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
  final TextEditingController _countryCodeController = TextEditingController();

  final AuthMethods _authMethods = AuthMethods();
  final FirestoreMethods _firestoreMethods = FirestoreMethods();
  bool _isLoading = false;
  late String verificationId; // For OTP verification

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _birthdayController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    _countryCodeController.dispose();
    super.dispose();
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
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.black),
                          onPressed: () {
                            _clearTextFields();
                            Navigator.pop(context);
                          },
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
                      Row(
                        children: [
                          SizedBox(
                            width: 140,
                            child: CustomizedTextfield(
                              myController: _countryCodeController,
                              hintText: "+91 (Code)",
                              isPassword: false,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          Expanded(
                            child: CustomizedTextfield(
                              myController: _phoneNumberController,
                              hintText: "Phone Number",
                              isPassword: false,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
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
                            _clearTextFields();
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
  String countryCode = _countryCodeController.text.trim();
  String phoneNumber = _phoneNumberController.text.trim();
  String fullPhoneNumber = '$countryCode$phoneNumber';
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

  // Check if the country code has exactly 3 characters and the phone number has 10 digits
  if (countryCode.length != 3 || !countryCode.startsWith('+')) {
    _showErrorDialog("Country code should be exactly 3 characters and start with '+'.");
    return;
  }

  if (phoneNumber.length != 10) {
    _showErrorDialog("Phone number should be exactly 10 digits.");
    return;
  }

  setState(() => _isLoading = true);

  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    User? user = userCredential.user;

    if (user != null) {
      await _firestoreMethods.saveUserData(
        AppUserModel.User(
          uid: user.uid,
          fullName: fullName,
          email: email,
          phoneNumber: fullPhoneNumber,
          birthday: birthday,
          location: location,
        ),
      );

      await user.sendEmailVerification();

      // Show a loading dialog before OTP screen redirection
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                const Expanded(child: Text("Redirecting to OTP screen...")),
              ],
            ),
          );
        },
      );

      // Initiate phone verification immediately after showing the dialog
      FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await user.linkWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          Navigator.pop(context); // Close loading dialog
          _showErrorDialog('Phone verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          this.verificationId = verificationId;
          Navigator.pop(context); // Close loading dialog
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => OtpScreen(verificationId: verificationId)),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    }
  } on FirebaseAuthException catch (e) {
    _showErrorDialog(e.message ?? "Registration failed. Please try again.");
  } finally {
    setState(() => _isLoading = false);
  }
}





  void _showInfoDialog(String message, VoidCallback onDialogClosed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Info"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDialogClosed();
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

  void _clearTextFields() {
    _fullNameController.clear();
    _emailController.clear();
    _phoneNumberController.clear();
    _birthdayController.clear();
    _locationController.clear();
    _passwordController.clear();
    _countryCodeController.clear();
  }
}
