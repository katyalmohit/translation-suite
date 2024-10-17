import 'package:flutter/material.dart';

class BackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const BackAppBar({
    Key? key,
    required this.title, required Null Function() onMorePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue, // Set the same blue color
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(top: 20), // Adjust padding to position the icon lower
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)), // Change icon color to white for contrast
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 20.0), // Adjust top padding for the title
        child: Text(
          title,
          style: const TextStyle(
            color: Color.fromARGB(255, 0, 0, 0), // White text for visibility
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      centerTitle: true, // Center the title
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70); // Set preferred size for AppBar
}
