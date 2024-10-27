import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:voicecall/firebase/wrapper.dart';
import 'package:voicecall/screens/edit_profile_screen.dart';
import '../widgets/back_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  File? _image;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();
      if (snapshot.exists) {
        setState(() {
          userData = snapshot.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      print("Failed to fetch user data: $e");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
  if (_image == null) {
    print("No image selected.");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select an image first.')),
    );
    return;
  }

  try {
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('${user?.uid}.jpg');

    print("Uploading image to Firebase Storage...");

    // Start the upload and wait for completion
    UploadTask uploadTask = ref.putFile(_image!);

    // Listen for upload task state changes
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      print('Upload state: ${snapshot.state}'); // Prints upload state
      print('Transferred: ${snapshot.bytesTransferred} bytes');
    });

    // Wait for the task to complete
    await uploadTask;

    print("Image uploaded successfully.");

    // Get the download URL
    String downloadURL = await ref.getDownloadURL();
    print("Download URL: $downloadURL");

    // Save the download URL to Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .update({
      'profileImage': downloadURL,
    });

    print("Profile image URL saved to Firestore.");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile picture updated!')),
    );
  } catch (e) {
    print("Error during upload: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Upload failed: $e')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BackAppBar(
        title: "My Profile",
        onMorePressed: () {},
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile picture and edit button
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: userData!['profileImage'] != null
                      ? NetworkImage(userData!['profileImage'])
                      : const AssetImage('assets/icon.jpg') as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: _pickImage, // Handle image upload
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // User details
            Text(
              userData!['fullName'] ?? 'N/A',
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              userData!['phoneNumber'] ?? 'N/A',
              style: const TextStyle(fontSize:18, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Location, Email, Birthday
            _buildDetailRow("LOCATION :", userData!['location'] ?? 'N/A'),
            _buildDetailRow("EMAIL :", userData!['email'] ?? 'N/A'),
            _buildDetailRow("BIRTHDAY :", userData!['birthday'] ?? 'N/A'),

            const SizedBox(height: 30),

            // Edit and Logout buttons side by side
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EditProfileScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(191, 246, 21, 5),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text("EDIT"),
                ),
                ElevatedButton(
                  onPressed: () => _logout(context), // Logout function call
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text("LOGOUT"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display user details in a row
  Widget _buildDetailRow(String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(value, style: const TextStyle(color: Colors.blue, fontSize: 16)),
        ],
      ),
    );
  }

  // Logout function
  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Wrapper()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString()}')),
      );
    }
  }
}
