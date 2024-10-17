import 'package:flutter/material.dart';
import 'package:voicecall/widgets/back_app_bar.dart';
import 'package:voicecall/widgets/custom_app_bar.dart'; // Import your custom app bar

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Function to save the profile
  void _saveProfile() {
    // Logic to save the profile goes here
    print("Profile saved: ${_nameController.text}, ${_emailController.text}");
    Navigator.pop(context); // Navigate back after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(
        title: "Edit Profile",
        onMorePressed: () {
          // Handle any more options if needed
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Name Field
            _buildTextField("Full name", _nameController),
            const SizedBox(height: 16),

            // Email Address Field
            _buildTextField("Email address", _emailController),
            const SizedBox(height: 16),

            // Phone Number Field
            _buildTextField("Phone number", _phoneController),
            const SizedBox(height: 16),

            // Birthday Field
            _buildTextField("Birthday", _birthdayController),
            const SizedBox(height: 16),

            // Location Field
            _buildTextField("Location", _locationController),
            const SizedBox(height: 30),

            // Button Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cancel Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Navigate back without saving
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey, // Grey color for the cancel button
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text("CANCEL"),
                ),
                // Save Button
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red background color for save
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text("SAVE"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
