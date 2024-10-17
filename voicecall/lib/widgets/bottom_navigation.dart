import 'package:flutter/material.dart';

class BottomNavigationWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigationWidget({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dialpad),
          label: 'Keypad',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Recents',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.contacts),
          label: 'Contacts',
        ),
      ],
      currentIndex: currentIndex, // Dynamically set the current index
      selectedItemColor: Colors.blue, // Active tab color
      unselectedItemColor: Colors.grey, // Inactive tab color
      backgroundColor: Colors.white, // Background color of BottomNavigationBar
      type: BottomNavigationBarType.fixed, // Prevent shifting of icons
      showSelectedLabels: true, // Show label for active tab
      showUnselectedLabels: true, // Show label for inactive tabs
      elevation: 8.0, // Add shadow to the bar
      onTap: (index) {
        // Call the onTap function passed from parent widget
        onTap(index);
      },
    );
  }
}
