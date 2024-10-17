import 'package:flutter/material.dart';
import 'package:voicecall/screens/new_contact.dart';
import 'package:voicecall/screens/profile_screen.dart';
import 'package:voicecall/translations/translation_screen.dart';
import 'package:voicecall/widgets/bottom_navigation.dart';
import 'package:voicecall/widgets/custom_app_bar.dart';

class KeypadScreen extends StatefulWidget {
  const KeypadScreen({super.key});

  @override
  State<KeypadScreen> createState() => _KeypadScreenState();
}

class _KeypadScreenState extends State<KeypadScreen> {
  String _enteredNumber = "";

  // Function to add digit to the entered number
  void _addDigit(String digit) {
    setState(() {
      _enteredNumber += digit;
    });
  }

  // Function to delete the last digit
  void _deleteLastDigit() {
    if (_enteredNumber.isNotEmpty) {
      setState(() {
        _enteredNumber = _enteredNumber.substring(0, _enteredNumber.length - 1);
      });
    }
  }

  // Show options for Profile and Translations
  void _showOptionsMenu(BuildContext context) async {
    await showMenu(
      color:const Color.fromARGB(255, 39, 196, 159),
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0), // Adjust position
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
          print('Profile selected');
        Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()), // Use the actual HomeScreen widget
                  );
          break;
        case 'translations':
          // Handle translations action
          Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TranslationsScreen()), // Use the actual HomeScreen widget
                  );
          break;
      }
    });
  }

  // Handle bottom navigation tap
  void _onBottomNavTap(int index) {
    switch (index) {
      case 0: // Keypad
        Navigator.pushReplacementNamed(context, '/keypad');
        break;
      case 1: // Recents
        Navigator.pushReplacementNamed(context, '/recents');
        break;
      case 2: // Contacts
        Navigator.pushReplacementNamed(context, '/contacts');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Keypad",
          onMorePressed: () {
            _showOptionsMenu(context); // Show three options menu
          },
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),

            // Add to Contacts Button at the top
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  _showAddContactOptions(context);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue, // Button color
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: const Text("Add to Contacts"),
              ),
            ),

            const SizedBox(height: 20),

            // Display entered number
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(51, 0, 0, 0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _enteredNumber.isEmpty ? "Enter number" : _enteredNumber,
                style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold,color: Color.fromARGB(255, 84, 86, 87)),
              ),
            ),

            const SizedBox(height: 20),

            // Number pad (1 to 9, *, 0, #)
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 columns for digits
                  childAspectRatio: 1.5, // Adjust aspect ratio for circles
                ),
                itemCount: 12, // 12 digits
                itemBuilder: (context, index) {
                  List<String> digits = [
                    '1', '2', '3',
                    '4', '5', '6',
                    '7', '8', '9',
                    '*', '0', '#'
                  ];
                  String digit = digits[index];

                  return InkWell(
                    onTap: () {
                      if (digit == 'Call') {
                        // Handle call action
                      } else {
                        _addDigit(digit);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 0, 0, 0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 5,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          digit,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Call and Delete buttons in the last row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Call button
                InkWell(
                  onTap: () {
                    // Handle call action
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.call, color: Colors.white, size: 30),
                    ),
                  ),
                ),
                // Delete button
                InkWell(
                  onTap: _deleteLastDigit,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.backspace, color: Colors.white, size: 30),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),

        // Bottom navigation bar - using the custom widget
        bottomNavigationBar: BottomNavigationWidget(
          currentIndex: 0, // Set 'Keypad' as the current tab
          onTap: _onBottomNavTap, // Call the navigation function
        ),
      ),
    );
  }
}

void _showAddContactOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add to Contacts",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text("Create New Contact"),
              onTap: () {
                // Handle creating a new contact
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NewContactScreen()), // Use the actual HomeScreen widget
                  );
              },
            ),
            ListTile(
              title: const Text("Update Existing Contact"),
              onTap: () {
                // Handle updating an existing contact
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NewContactScreen()), // Use the actual HomeScreen widget
                  );
                print("Update existing contact tapped");
              },
            ),
            const SizedBox(height: 10),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    },
  );
}
