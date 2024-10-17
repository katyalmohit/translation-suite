import 'package:flutter/material.dart';
import 'package:voicecall/screens/profile_screen.dart';
import 'package:voicecall/translations/translation_screen.dart';
import 'package:voicecall/widgets/bottom_navigation.dart';
import 'package:voicecall/widgets/custom_app_bar.dart'; // Import the CustomAppBar

class RecentScreen extends StatefulWidget {
  const RecentScreen({super.key});

  @override
  State<RecentScreen> createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen> {
  // Dummy list of recent contacts
  final List<Map<String, String>> recentContacts = [
    {
      'name': 'Mr. Rohan Kumar',
      'number': '+99897 565 71 73',
    },
    {
      'name': 'Mr. Amit Sharma',
      'number': '+99897 565 71 73',
    },
    {
      'name': 'Mr. Anshul Goyal',
      'number': '+99897 565 71 73',
    },
    {
      'name': 'Mr. Rohan Kumar',
      'number': '+99897 565 71 73',
    },
    {
      'name': 'Mr. Amit Sharma',
      'number': '+99897 565 71 73',
    },
    {
      'name': 'Mr. Anshul Goyal',
      'number': '+99897 565 71 73',
    },
    // Add more contacts as needed
  ];

  List<bool> selectedContacts = []; // To track selected contacts
  String _searchQuery = '';
  bool _isDeleteMode = false; // Track if we are in delete mode

  @override
  void initState() {
    super.initState();
    // Initialize the selectedContacts list based on recentContacts length
    selectedContacts = List.generate(recentContacts.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Recent Calls",
          onMorePressed: () {
            _showPopupMenu(context); // Show three-dot menu
          },
        ),
        body: Column(
          children: [
            const SizedBox(height: 10), // Spacing between Recent Calls and Search bar

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 240, 230, 240),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey), // Left search icon
                  hintText: "Search Contacts",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // Recent Contacts List
            Expanded(
              child: ListView.builder(
                itemCount: recentContacts.length,
                itemBuilder: (context, index) {
                  String name = recentContacts[index]['name'] ?? '';
                  String number = recentContacts[index]['number'] ?? '';

                  // Filter contacts based on search query
                  if (_searchQuery.isNotEmpty &&
                      !name.toLowerCase().contains(_searchQuery.toLowerCase())) {
                    return Container();
                  }

                  return ListTile(
                    leading: _isDeleteMode
                        ? Checkbox(
                            value: selectedContacts[index],
                            onChanged: (bool? value) {
                              setState(() {
                                selectedContacts[index] = value ?? false;
                              });
                            },
                          )
                        : const CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage('assets/icon.jpg'), // Using icon.png as the avatar
                          ),
                    title: Text(name),
                    subtitle: Text(number),
                    trailing: IconButton(
                      icon: const Icon(Icons.call, color: Colors.green),
                      onPressed: () {
                        // Handle call action
                      },
                    ),
                  );
                },
              ),
            ),

            // Delete Button with Trash Icon
            if (_isDeleteMode) // Show delete button only in delete mode
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: selectedContacts.every((element) => element), // Check if all are selected
                          onChanged: (bool? value) {
                            setState(() {
                              for (int i = 0; i < selectedContacts.length; i++) {
                                selectedContacts[i] = value ?? false; // Select or deselect all
                              }
                            });
                          },
                        ),
                        const Text('Select All'), // Text for the select all checkbox
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red), // Trash icon
                      onPressed: _deleteSelectedContacts,
                    ),
                  ],
                ),
              ),
          ],
        ),
        bottomNavigationBar: BottomNavigationWidget(
          currentIndex: 1, // Set 'Recents' as the current tab
          onTap: _onBottomNavTap,
        ),
      ),
    );
  }

  void _deleteSelectedContacts() {
    setState(() {
      for (int i = selectedContacts.length - 1; i >= 0; i--) {
        if (selectedContacts[i]) {
          recentContacts.removeAt(i);
          selectedContacts.removeAt(i);
        }
      }
      _isDeleteMode = false; // Exit delete mode after deletion
    });
  }

  // Handle bottom navigation tap
  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        // Navigate to Keypad screen
        Navigator.pushReplacementNamed(context, '/keypad');
        break;
      case 1:
        // Current screen is Recent, no need to navigate
        break;
      case 2:
        // Navigate to Contacts screen
        Navigator.pushReplacementNamed(context, '/contacts');
        break;
    }
  }

  // Show the popup menu with options (Delete, Profile, Translations)
  void _showPopupMenu(BuildContext context) async {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;

    await showMenu(
      color: const Color.fromARGB(255, 39, 196, 159),
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(
          overlay.size.width - 40, // Adjusted position for proper alignment
          80, // Position the menu just below the three-dot icon
          100,
          100,
        ),
        Offset.zero & overlay.size,
      ),
      items: [
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text('Delete'),
        ),
        const PopupMenuItem<String>(
          value: 'profile',
          child: Text('Profile'),
        ),
        const PopupMenuItem<String>(
          value: 'translations',
          child: Text('Translations'),
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      // Handle menu option selection
      switch (value) {
        case 'delete':
          setState(() {
            _isDeleteMode = true; // Enter delete mode
          });
          break;
        case 'profile':
          // Handle profile
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
          break;
        case 'translations':
          // Handle translations
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TranslationsScreen()),
          );
          break;
      }
    });
  }
}
