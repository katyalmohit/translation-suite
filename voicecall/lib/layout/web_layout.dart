import 'package:flutter/material.dart';
import 'package:voicecall/utils/global_variables.dart';

class WebScreenLayout extends StatefulWidget {
  const WebScreenLayout({super.key});

  @override
  State<WebScreenLayout> createState() => _WebScreenLayoutState();
}

class _WebScreenLayoutState extends State<WebScreenLayout> {
  int _currentIndex = 0; // Track the current index of the selected tab

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index; // Update index on navigation tap
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Layout'),
        backgroundColor: Colors.black,
      ),
      body: Row(
        children: [
          // Keypad screen always visible on the left
          Expanded(
            flex: 1,
            child: homeScreenItems[0], // Always display KeypadScreen
          ),
          // Main content area for displaying the selected screen
          Expanded(
            flex: 3,
            child: homeScreenItems[_currentIndex], // Display the selected screen
          ),
          // Bottom navigation on the right side
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                BottomNavigationBar(
                  currentIndex: _currentIndex, // Highlight the selected tab
                  onTap: _onItemTapped, // Handle navigation taps
                  selectedItemColor: Colors.blue, // Color for the active tab
                  unselectedItemColor: Colors.grey, // Color for inactive tabs
                  type: BottomNavigationBarType.fixed, // Prevent shifting
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
