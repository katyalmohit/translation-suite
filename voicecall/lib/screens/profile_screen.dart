import 'package:flutter/material.dart';
import 'package:voicecall/screens/edit_profile_screen.dart';
import 'package:voicecall/widgets/back_app_bar.dart';
import 'package:voicecall/widgets/custom_app_bar.dart'; // Import your custom app bar

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BackAppBar(
        title: "My Profile", // Set the title for the app bar
        onMorePressed: () {
          // Handle more options if needed
        },
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
                  child: ClipOval(
                    child: Image.asset(
                      'assets/icon.jpg', // Replace with your profile picture asset
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
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
                      onPressed: () {
                        // Handle image upload
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // User details
            const Text(
              "ROHAN KUMAR",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              "+91 9989756748",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Location, Email, Birthday
            _buildDetailRow("LOCATION :", "DELHI"),
            _buildDetailRow("EMAIL :", "ROHANK@GMAIL.COM"),
            _buildDetailRow("BIRTHDAY :", "01/01/2004"),

            const SizedBox(height: 30),

            // Edit button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()), // Use the actual HomeScreen widget
                  );
                // Handle edit action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(191, 246, 21, 5), // Background color for the edit button
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: const TextStyle(fontSize: 18), // Font size for the button text
              ),

              child: const Text("EDIT"),
              

            ),
          ],
        ),
      ),
    );
  }

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
}
