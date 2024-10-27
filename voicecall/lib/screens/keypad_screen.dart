import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:voicecall/screens/new_contact.dart';
import 'package:voicecall/screens/profile_screen.dart';
import 'package:voicecall/screens/contact_profile_screen.dart';
import 'package:voicecall/translations/translation_screen.dart';
import '../widgets/custom_app_bar.dart';

class KeypadScreen extends StatefulWidget {
  const KeypadScreen({super.key});

  @override
  State<KeypadScreen> createState() => _KeypadScreenState();
}

class _KeypadScreenState extends State<KeypadScreen> {
  String _enteredNumber = "";

  // Add digit to the entered number
  void _addDigit(String digit) {
    setState(() {
      _enteredNumber += digit;
    });
  }

  // Delete the last digit
  void _deleteLastDigit() {
    if (_enteredNumber.isNotEmpty) {
      setState(() {
        _enteredNumber =
            _enteredNumber.substring(0, _enteredNumber.length - 1);
      });
    }
  }

  // Show Bottom Sheet with Contact Options
  void _showAddContactOptions() {
    if (_enteredNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number.')),
      );
      return;
    }
  showModalBottomSheet(
  context: context,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
  builder: (context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      height: 250, // Set height to increase the size of the bottom sheet
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Add to Contacts", // Title at the top of the bottom sheet
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20), // Space between title and options
          ListTile(
            leading: const Icon(Icons.person_add, color: Colors.blue),
            title: const Text('Create New Contact'),
            onTap: () {
              Navigator.pop(context); // Close bottom sheet
              _navigateToNewContactScreen();
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.green),
            title: const Text('Update Existing Contact'),
            onTap: () {
              Navigator.pop(context); // Close bottom sheet
              _navigateToContactProfileScreen();
            },
          ),
        ],
      ),
    );
  },
);

  }

  // Navigate to New Contact Screen
  void _navigateToNewContactScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewContactScreen(phoneNumber: _enteredNumber),
      ),
    );
  }

  // Navigate to Contact Profile Screen (Pass Example Data for Now)
void _navigateToContactProfileScreen() async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('contacts')
      .where('phone', isEqualTo: _enteredNumber)
      .get();

  if (querySnapshot.docs.isEmpty) {
    // If no contact is found, prompt to create a new contact
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact not found. Create a new contact.')),
    );
    _navigateToNewContactScreen(); // Navigate to create new contact
  } else {
    // If contact exists, navigate to ContactProfileScreen
    final contactData = querySnapshot.docs.first.data();
    contactData['id'] = querySnapshot.docs.first.id; // Add document ID

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactProfileScreen(contact: contactData),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Keypad",
          onMorePressed: () => _showOptionsMenu(context),
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            _buildAddContactButton(),
            const SizedBox(height: 20),
            _buildEnteredNumberDisplay(),
            const SizedBox(height: 20),
            _buildNumberPad(),
            _buildCallAndDeleteButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Add to Contacts Button
  Widget _buildAddContactButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ElevatedButton(
        onPressed: _showAddContactOptions, // Show bottom sheet with options
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
        child: const Text("Add to Contacts"),
      ),
    );
  }

  // Display the Entered Number
  Widget _buildEnteredNumberDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(51, 0, 0, 0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _enteredNumber.isEmpty ? "Enter number" : _enteredNumber,
        style: const TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 16, 16, 16)),
      ),
    );
  }

  // Number Pad (1-9, *, 0, #)
  Widget _buildNumberPad() {
    List<String> digits = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '*',
      '0',
      '#'
    ];
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.5,
        ),
        itemCount: digits.length,
        itemBuilder: (context, index) {
          String digit = digits[index];
          return InkWell(
            onTap: () => _addDigit(digit),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
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
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Call and Delete Buttons
  Widget _buildCallAndDeleteButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCircleButton(
          color: Colors.green,
          icon: Icons.call,
          onTap: () {
            print('Calling $_enteredNumber');
          },
        ),
        _buildCircleButton(
          color: Colors.red,
          icon: Icons.backspace,
          onTap: _deleteLastDigit,
        ),
      ],
    );
  }

  // Reusable Circle Button Widget
  Widget _buildCircleButton({
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 30,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  // Options Menu for Profile and Translations
  void _showOptionsMenu(BuildContext context) async {
    await showMenu(
      color: const Color.fromARGB(255, 39, 196, 159),
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        const PopupMenuItem(value: 'profile', child: Text('Profile')),
        const PopupMenuItem(value: 'translations', child: Text('Translations')),
      ],
    ).then((value) {
      if (value == 'profile') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
      } else if (value == 'translations') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const TranslationsScreen()),
        );
      }
    });
  }
}
