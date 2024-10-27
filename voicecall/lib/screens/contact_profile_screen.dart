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
    _locationController =
        TextEditingController(text: widget.contact['location']);
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

  Future<void> _saveContact() async {
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
      });
    } catch (e) {
      print('Failed to update contact: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update contact')),
      );
    }
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
          onPressed: _saveContact,
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
          onPressed: () {
            setState(() {
              _isEditing = false;
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
