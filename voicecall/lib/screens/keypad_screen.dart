import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voicecall/screens/audio_calling_screen.dart';
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
  List<Map<String, dynamic>> _contacts = []; // Store user's contacts

  @override
  void initState() {
    super.initState();
    _fetchUserContacts(); // Fetch contacts when the screen is initialized
  }

  // Fetch user's contacts from Firestore
  Future<void> _fetchUserContacts() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        List<dynamic> contacts = userDoc['contacts'] ?? [];
        setState(() {
          _contacts = contacts.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch contacts.')),
      );
    }
  }

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
        _enteredNumber = _enteredNumber.substring(0, _enteredNumber.length - 1);
      });
    }
  }

  // Validate phone number format
  bool _isValidPhoneNumber(String phoneNumber) {
    final regex = RegExp(r'^\+?[0-9]{10,15}$');
    return regex.hasMatch(phoneNumber);
  }

  // Show Bottom Sheet with Contact Options
  Future<void> _showAddContactOptions() async {
    if (_enteredNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number.')),
      );
      return;
    }

    // Check if contact already exists
    bool contactExists = _contacts.any((contact) =>
        contact['phone'] != null && contact['phone'] == _enteredNumber);

    if (contactExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This contact already exists.')),
      );
      _navigateToContactProfileScreen();
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
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add to Contacts",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.person_add, color: Colors.blue),
                title: const Text('Create New Contact'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToNewContactScreen();
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.green),
                title: const Text('Update Existing Contact'),
                onTap: () {
                  Navigator.pop(context);
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

  // Navigate to Contact Profile Screen
  void _navigateToContactProfileScreen() {
    Map<String, dynamic>? contact = _contacts.firstWhere(
      (contact) => contact['phone'] == _enteredNumber,
      orElse: () => {}, // Return an empty map if no match is found
    );

    if (contact.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Contact not found. Create a new contact.')),
      );
      _navigateToNewContactScreen();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContactProfileScreen(contact: contact),
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

  Widget _buildAddContactButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ElevatedButton(
        onPressed: _showAddContactOptions,
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
          color: Color.fromARGB(255, 16, 16, 16),
        ),
      ),
    );
  }

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
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

void _initiateCall() async {
  if (_enteredNumber.isEmpty || !_isValidPhoneNumber(_enteredNumber)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a valid phone number.')),
    );
    return;
  }

  try {
    // Check if the recipient exists by phone number
    QuerySnapshot userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('user_details.phoneNumber', isEqualTo: _enteredNumber)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      // Recipient does not exist
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User with this phone number does not exist.')),
      );
      return;
    }

    // Retrieve current user and recipient details
    // String currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    Future<String> _getCallerPhoneNumber(String uid) async {
      try {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists) {
          return userDoc['user_details']['phoneNumber'] ?? 'Unknown';
        }
      } catch (e) {
        print('Error fetching caller phone number: $e');
      }
      return 'Unknown';
    }

    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    String callerPhoneNumber = await _getCallerPhoneNumber(currentUserUid);

    String recipientUid = userQuery.docs.first.id;
    String recipientPhoneNumber = _enteredNumber;

    // Create a new document in the 'ongoingCalls' collection
    String callId = FirebaseFirestore.instance.collection('ongoingCalls').doc().id;

    await FirebaseFirestore.instance.collection('ongoingCalls').doc(callId).set({
      'callerUid': currentUserUid,
      'callerPhoneNumber': callerPhoneNumber,
      'acceptorUid': recipientUid,
      'acceptorPhoneNumber': recipientPhoneNumber,
      'callId': callId,
      'status': 'placed',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Navigate to the call screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioCallingScreen(
          enteredNumber: _enteredNumber,
          recipientUid: recipientUid,
          callId: callId,
        ),
      ),
    );
  } catch (e) {
    print('Error initiating call: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to initiate call. Please try again.')),
    );
  }
}


// Replace the `_buildCircleButton` for the call button
Widget _buildCallAndDeleteButtons() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      _buildCircleButton(
        color: Colors.green,
        icon: Icons.call,
        onTap: _initiateCall,
      ),
      _buildCircleButton(
        color: Colors.red,
        icon: Icons.backspace,
        onTap: _deleteLastDigit,
      ),
    ],
  );
}


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
      } 
      // else if (value == 'translations') {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => const TranslationsScreen()),
      //   );
      // }
    });
  }
}
