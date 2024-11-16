import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ContactProfileScreen extends StatefulWidget {
  final Map<String, dynamic> contact;

  const ContactProfileScreen({super.key, required this.contact});

  @override
  State<ContactProfileScreen> createState() => _ContactProfileScreenState();
}

class _ContactProfileScreenState extends State<ContactProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  bool _isEditing = false;
  bool _isSaving = false; // Track the saving/loading state
  File? _newImageFile;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact['name']);
    _phoneController = TextEditingController(text: widget.contact['phone']);
    _emailController = TextEditingController(text: widget.contact['email']);
    _locationController = TextEditingController(text: widget.contact['location']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_newImageFile == null) return null;

    try {
      final ref = _storage
          .ref()
          .child('contacts/${widget.contact['id']}/${DateTime.now()}.jpg');
      await ref.putFile(_newImageFile!);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Failed to upload image: $e');
      return null;
    }
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
    if (!RegExp(r'^\d+$').hasMatch(phone)) {
      return "Phone number should contain only digits.";
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

    setState(() => _isSaving = true); // Show loading indicator

    String? imageUrl = widget.contact['imageUrl'];
    if (_newImageFile != null) {
      imageUrl = await _uploadImage();
    }

    try {
      await _firestore.collection('contacts').doc(widget.contact['id']).update({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'location': _locationController.text,
        'imageUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact updated successfully!')),
      );

      setState(() {
        _isEditing = false;
        _isSaving = false; // Hide loading indicator
      });
    } catch (e) {
      print('Failed to update contact: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update contact')),
      );
      setState(() => _isSaving = false); // Hide loading indicator
    }
  }

  // Error dialog to display validation errors
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Contact' : widget.contact['name'] ?? 'Contact',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss the keyboard on tap
        child: SingleChildScrollView( // Prevents overflow issues
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _isEditing ? _pickImage : null,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.indigo.shade100,
                    backgroundImage: _newImageFile != null
                        ? FileImage(_newImageFile!)
                        : widget.contact['imageUrl'] != null &&
                                widget.contact['imageUrl'].isNotEmpty
                            ? NetworkImage(widget.contact['imageUrl'])
                            : const AssetImage('assets/icon.jpg')
                                as ImageProvider,
                    child: _isEditing
                        ? const Icon(Icons.camera_alt,
                            size: 30, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField('Name', _nameController, Icons.person),
              const SizedBox(height: 25),
              _buildTextField('Phone', _phoneController, Icons.phone),
              const SizedBox(height: 25),
              _buildTextField('Email', _emailController, Icons.email),
              const SizedBox(height: 25),
              _buildTextField('Location', _locationController, Icons.location_on),
              const SizedBox(height: 25),
              if (_isEditing) _buildSaveAndCancelButtons(),
              if (_isSaving)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                ), // Show loading spinner
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      enabled: _isEditing,
      style: const TextStyle(
        color: Color.fromARGB(124, 0, 0, 0), // Change the text color to black (or any color)
        fontSize: 18, // Optional: Increase font size for better visibility
        fontWeight: FontWeight.w500, // Optional: Adjust font weight
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.grey, // Change the label text color
          fontWeight: FontWeight.bold, // Optional: Bold label
        ),
        prefixIcon: Icon(icon, color: Colors.indigo),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        filled: true, // Add fill color for better visibility
        fillColor: const Color.fromARGB(255, 230, 230, 250), // Light background color
      ),
    );
  }

  Widget _buildSaveAndCancelButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: _isSaving ? null : _saveContact, // Disable button when saving
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Save',
            style: TextStyle(fontSize: 18),
          ),
        ),
        ElevatedButton(
          onPressed: _isSaving
              ? null
              : () {
                  setState(() {
                    _isEditing = false;
                    _newImageFile = null; // Reset the image file if edit is canceled
                  });
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}
