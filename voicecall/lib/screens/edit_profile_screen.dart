import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/back_app_bar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user?.uid).get();
      if (doc.exists) {
        var userData = doc.data() as Map<String, dynamic>;
        var userDetails = userData['user_details'] ?? {};
        setState(() {
          _nameController.text = userDetails['userName'] ?? '';
          _birthdayController.text = userDetails['birthday'] ?? '';
          _locationController.text = userDetails['location'] ?? '';
          _emailController.text = userDetails['email'] ?? '';
          _phoneController.text = userDetails['phoneNumber'] ?? '';
        });
      }
    } catch (e) {
      print('Failed to fetch user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch user data.')),
      );
    }
  }

  String? _validateUserName(String userName) {
    if (userName.isEmpty) return "User Name cannot be empty.";
    if (RegExp(r'^\d+$').hasMatch(userName)) {
      return "User Name cannot be entirely numbers.";
    }
    return null;
  }

  String? _validateBirthday(String birthday) {
    if (birthday.isEmpty) return "Birthday cannot be empty.";
    try {
      final dateParts = birthday.split('/');
      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);
      DateTime birthDate = DateTime(year, month, day);
      if (birthDate.isAfter(DateTime.now())) {
        return "Birthday cannot be in the future.";
      }
    } catch (_) {
      return "Enter a valid date in DD/MM/YYYY format.";
    }
    return null;
  }

  String? _validateLocation(String location) {
    if (location.isEmpty) return "Location cannot be empty.";
    if (RegExp(r'^\d+$').hasMatch(location)) {
      return "Location cannot be entirely numbers.";
    }
    return null;
  }

  Future<void> _saveProfile() async {
    String userName = _nameController.text.trim();
    String birthday = _birthdayController.text.trim();
    String location = _locationController.text.trim();

    String? userNameError = _validateUserName(userName);
    if (userNameError != null) {
      _showDialog(userNameError);
      return;
    }

    String? birthdayError = _validateBirthday(birthday);
    if (birthdayError != null) {
      _showDialog(birthdayError);
      return;
    }

    String? locationError = _validateLocation(location);
    if (locationError != null) {
      _showDialog(locationError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Update user data in Firestore under `user_details`
      Map<String, dynamic> updatedUserData = {
        'user_details.userName': userName,
        'user_details.birthday': birthday,
        'user_details.location': location,
        'user_details.email': _emailController.text, // Keep email for display
        'user_details.phoneNumber': _phoneController.text, // Keep phone for display
      };
      await _firestore.collection('users').doc(user?.uid).update(updatedUserData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      // Pass updated data back to ProfileScreen
      Navigator.pop(context, updatedUserData);
    } catch (e) {
      print('Failed to update profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(
        title: "Edit Profile",
        onMorePressed: () {},
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("User Name", _nameController),
              const SizedBox(height: 16),

              _buildInteractiveTextField(
                "Email Address", _emailController,
                "You cannot edit the email address.",
              ),
              const SizedBox(height: 16),

              _buildInteractiveTextField(
                "Phone Number", _phoneController,
                "You cannot edit the phone number.",
              ),
              const SizedBox(height: 16),

              _buildTextField("Birthday", _birthdayController),
              const SizedBox(height: 16),

              _buildTextField("Location", _locationController),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text("CANCEL"),
                  ),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text("SAVE"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 33, 33, 33),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildInteractiveTextField(
      String label, TextEditingController controller, String dialogMessage) {
    return GestureDetector(
      onTap: () => _showDialog(dialogMessage),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 33, 33, 33),
          borderRadius: BorderRadius.circular(8),
        ),
        child: AbsorbPointer(
          child: TextField(
            controller: controller,
            enabled: false,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.white),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
