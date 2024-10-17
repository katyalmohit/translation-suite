import 'package:flutter/material.dart';
import 'package:voicecall/screens/profile_screen.dart';
import 'package:voicecall/translations/translation_screen.dart';
import 'package:voicecall/widgets/bottom_navigation.dart';
import 'package:voicecall/widgets/custom_app_bar.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  // Dummy list of contacts
  final List<Map<String, String>> contacts = [
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

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Contacts",
          onMorePressed: () {
            _showPopupMenu(context); // Show three-dot menu
          },
        ),
        body: Column(
          children: [
            const SizedBox(height: 10), // Spacing between Contacts and Search bar

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

            // Contacts List
            Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  String name = contacts[index]['name'] ?? '';
                  String number = contacts[index]['number'] ?? '';

                  // Filter contacts based on search query
                  if (_searchQuery.isNotEmpty &&
                      !name.toLowerCase().contains(_searchQuery.toLowerCase())) {
                    return Container();
                  }

                  return ListTile(
                    leading: const CircleAvatar(
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
          ],
        ),
        bottomNavigationBar: BottomNavigationWidget(
          currentIndex: 2, // Set 'Contacts' as the current tab
          onTap: _onBottomNavTap,
        ),
      ),
    );
  }

  // Handle bottom navigation tap
  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        // Navigate to Keypad screen
        Navigator.pushReplacementNamed(context, '/keypad');
        break;
      case 1:
        // Navigate to Recent screen
        Navigator.pushReplacementNamed(context, '/recents');
        break;
      case 2:
        // Current screen is Contacts, no need to navigate
        break;
    }
  }

  // Show the popup menu with options (Profile, Translations)
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
        case 'profile':
          // Handle profile action
        Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()), // Use the actual HomeScreen widget
                  );
             break;
        case 'translations':
          // Handle translations action
          print('Translations selected');
          Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TranslationsScreen()), // Use the actual HomeScreen widget
                  ); 
          break;
      }
    });
  }
}
