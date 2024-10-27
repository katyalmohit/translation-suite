import 'package:flutter/material.dart';
import 'package:voicecall/utils/global_variables.dart';

class MobileScreenLayout extends StatefulWidget {
  final int initialPage;

  const MobileScreenLayout({super.key, this.initialPage = 0});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  late int _page; // Track the current page
  late PageController pageController; // Controller for the PageView

  @override
  void initState() {
    super.initState();
    _page = widget.initialPage; // Initialize the current page
    pageController = PageController(initialPage: _page); // Set initial page
  }

  @override
  void dispose() {
    pageController.dispose(); // Dispose the controller when not needed
    super.dispose();
  }

  // Navigate to the selected page with animation
  void navigationTapped(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Update the current page index when a new page is selected
  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea( // Ensures layout is within safe UI boundaries
      child: Scaffold(
        body: PageView(
          physics: const NeverScrollableScrollPhysics(), // Disable swipe navigation
          controller: pageController, // Assign the controller
          onPageChanged: onPageChanged, // Handle page changes
          children: homeScreenItems, // Load screens from global variables
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _page, // Track the selected tab
          onTap: navigationTapped, // Handle tab changes
          selectedItemColor: Colors.blue, // Active tab color
          unselectedItemColor: Colors.grey, // Inactive tab color
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
      ),
    );
  }
}
