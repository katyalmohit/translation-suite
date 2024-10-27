import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/back_app_bar.dart'; // Import your custom app bar

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch data on screen load
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user?.uid).get();
      if (doc.exists) {
        var userData = doc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = userData['fullName'] ?? '';
          _phoneController.text = userData['phoneNumber'] ?? '';
          _birthdayController.text = userData['birthday'] ?? '';
          _locationController.text = userData['location'] ?? '';
          _emailController.text = userData['email'] ?? '';
        });
      }
    } catch (e) {
      print('Failed to fetch user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch user data.')),
      );
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true); // Start loading indicator

    try {
      await _firestore.collection('users').doc(user?.uid).update({
        'fullName': _nameController.text,
        'birthday': _birthdayController.text,
        'location': _locationController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      Navigator.pop(context); // Navigate back after saving
    } catch (e) {
      print('Failed to update profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile.')),
      );
    } finally {
      setState(() => _isLoading = false); // Stop loading indicator
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Information'),
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
              _buildTextField("Full name", _nameController),
              const SizedBox(height: 16),

              _buildInteractiveTextField(
                "Email address", _emailController, 
                "You cannot edit the email address."
              ),
              const SizedBox(height: 16),

              _buildInteractiveTextField(
                "Phone number", _phoneController, 
                "You cannot edit the phone number."
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

  // Build editable text field
  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 33, 5, 5),
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

  // Build interactive text field with tap functionality
  Widget _buildInteractiveTextField(
      String label, TextEditingController controller, String dialogMessage) {
    return GestureDetector(
      onTap: () => _showDialog(dialogMessage),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 33, 5, 5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: AbsorbPointer( // Prevents editing
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
