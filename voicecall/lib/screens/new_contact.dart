import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/back_app_bar.dart'; // Import custom app bar

class NewContactScreen extends StatefulWidget {
  final String phoneNumber; // Accept phone number from KeypadScreen

  const NewContactScreen({super.key, required this.phoneNumber});

  @override
  State<NewContactScreen> createState() => _NewContactScreenState();
}

class _NewContactScreenState extends State<NewContactScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  XFile? _image; // Store selected image
  bool _isSaving = false; // Track saving state

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.phoneNumber; // Pre-fill phone number
  }

  // Validation functions
  String? _validateName(String name) {
    if (name.isEmpty) return "Name cannot be empty.";
    if (RegExp(r'^\d+$').hasMatch(name)) {
      return "Name cannot be entirely numbers.";
    }
    return null;
  }

  String? _validatePhoneNumber(String phone) {
    if (phone.isEmpty) return "Phone number cannot be empty.";
    if (phone.length > 12 || !RegExp(r'^\d+$').hasMatch(phone)) {
      return "Phone number should be exactly 10 digits.";
    }
    return null;
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) return null; // Optional field, no error if empty
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(email)) {
      return "Enter a valid email address.";
    }
    return null;
  }

  String? _validateLocation(String location) {
    if (RegExp(r'^\d+$').hasMatch(location)) {
      return "Location cannot be entirely numbers.";
    }
    return null;
  }

  // Function to pick an image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    _image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {}); // Refresh UI with selected image
  }

  // Function to save contact to Firestore with duplicate check
// Function to save contact to Firestore with duplicate check and loading indicator
  Future<void> _saveContact() async {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String email = _emailController.text.trim();
    String location = _locationController.text.trim();

    // Validate fields sequentially and show first error found
    String? nameError = _validateName(name);
    if (nameError != null) {
      _showErrorDialog(nameError);
      return;
    }

    String? phoneError = _validatePhoneNumber(phone);
    if (phoneError != null) {
      _showErrorDialog(phoneError);
      return;
    }

    String? emailError = _validateEmail(email);
    if (emailError != null) {
      _showErrorDialog(emailError);
      return;
    }

    String? locationError = _validateLocation(location);
    if (locationError != null) {
      _showErrorDialog(locationError);
      return;
    }

    // if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Name and Phone number are required.')),
    //   );
    //   return;
    // }

    setState(() => _isSaving = true); // Show loading spinner

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text("Adding contact...")),
            ],
          ),
        );
      },
    );

    try {
      String userId = _currentUser?.uid ?? '';
      String phoneNumber = _phoneController.text.trim();

      // Check if contact with the same phone number already exists for this user
      final QuerySnapshot existingContact = await _firestore
          .collection('contacts')
          .where('userId', isEqualTo: userId)
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (existingContact.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This contact already exists.')),
        );
        setState(() => _isSaving = false); // Stop loading spinner
        return;
      }

      String? imageUrl;

      // If image is selected, upload it to Firebase Storage
      if (_image != null) {
        final ref = FirebaseStorage.instance.ref().child(
            'contacts/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(File(_image!.path));
        imageUrl = await ref.getDownloadURL();
      }

      // Create a new contact document in Firestore
      await _firestore.collection('contacts').add({
        'name': _nameController.text,
        'phone': phoneNumber,
        'email':
            _emailController.text.isNotEmpty ? _emailController.text : null,
        'location': _locationController.text.isNotEmpty
            ? _locationController.text
            : null,
        'imageUrl': imageUrl,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact saved successfully!')),
      );

      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      print('Failed to save contact: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save contact.')),
      );
    } finally {
      setState(() => _isSaving = false); // Stop loading spinner
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(
        title: "Create New Contact",
        onMorePressed: () {},
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        _image != null ? FileImage(File(_image!.path)) : null,
                    child: _image == null
                        ? const Icon(Icons.camera_alt, size: 30)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField("Name", _nameController),
              const SizedBox(height: 16),
              _buildTextField("Phone Number", _phoneController),
              const SizedBox(height: 16),
              _buildTextField("Email", _emailController),
              const SizedBox(height: 16),
              _buildTextField("Location", _locationController),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildButton("Cancel", () {
                    Navigator.pop(context);
                  }, Colors.red),
                  _buildButton("Save", _saveContact, Colors.blue),
                ],
              ),
              if (_isSaving)
                const Center(
                    child: CircularProgressIndicator()), // Show spinner
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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

  Widget _buildButton(String label, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(label),
    );
  }
  
void _showErrorDialog(String message) {
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
}
