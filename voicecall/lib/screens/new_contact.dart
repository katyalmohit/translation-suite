import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import this for image picking
import 'package:voicecall/widgets/back_app_bar.dart';
import 'package:voicecall/widgets/custom_app_bar.dart'; // Import the custom app bar

class NewContactScreen extends StatefulWidget {
  const NewContactScreen({super.key});

  @override
  State<NewContactScreen> createState() => _NewContactScreenState();
}

class _NewContactScreenState extends State<NewContactScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  XFile? _image; // Variable to store the selected image

  // Function to save the contact
  void _saveContact() {
    // Logic to save the contact goes here
    Navigator.pop(context); // Close the screen after saving
  }

  // Function to pick an image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    _image = await picker.pickImage(source: ImageSource.gallery); // Allow picking from gallery
    setState(() {}); // Refresh the UI to show the selected image
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(
        title: "New Contact",
        onMorePressed: () {}, // No action for the three dots
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Enable scrolling for smaller screens
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile image
              Center(
                child: GestureDetector(
                  onTap: _pickImage, // Call the function to pick an image
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _image != null ? FileImage(File(_image!.path)) : null,
                    child: _image == null 
                        ? const Icon(Icons.camera_alt, size: 30) 
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Name Field
              _buildTextField("Name", _nameController),
              const SizedBox(height: 16),
              
              // Phone Number Field
              _buildTextField("Phone Number", _phoneController),
              const SizedBox(height: 16),
              
              // Email Field
              _buildTextField("Email", _emailController),
              const SizedBox(height: 20),
              
              // Cancel and Save buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildButton("Cancel", () {
                    Navigator.pop(context); // Cancel action
                  }, Colors.red), // Change button color to red
                  _buildButton("Save", _saveContact, Colors.blue),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build styled text fields
  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Function to build styled buttons
  Widget _buildButton(String label, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color, // Set button color dynamically
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
      ),
      child: Text(label),
    );
  }
}
