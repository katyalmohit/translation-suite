import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voicecall/screens/audio_calling_screen.dart';
import 'package:voicecall/screens/contact_profile_screen.dart';
import 'package:voicecall/screens/profile_screen.dart';
import 'package:voicecall/translations/translation_screen.dart';
import '../widgets/custom_app_bar.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isDeleteMode = false;
  bool _selectAll = false;
  bool _isContactsLoaded = false;

  String _searchQuery = '';
  List<Map<String, dynamic>> _contacts = [];

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  // Fetch contacts from the `contacts` field in the user's document
  Future<void> _fetchContacts() async {
    try {
      String userId = _auth.currentUser?.uid ?? '';

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        List<dynamic> contacts = userDoc['contacts'] ?? [];
        setState(() {
          _contacts = contacts.map((e) => Map<String, dynamic>.from(e)).toList();
          _isContactsLoaded = true;
        });

        if (_contacts.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contacts loaded successfully!')),
          );
        }
      }
    } catch (e) {
      print('Error fetching contacts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load contacts')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Contacts",
          onMorePressed: () => _showPopupMenu(context),
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),
            _buildSearchBar(),
            if (_isDeleteMode) _buildSelectAllCheckbox(),
            if (!_isContactsLoaded)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else
              _buildContactsList(),
          ],
        ),
        floatingActionButton: _isDeleteMode && _contacts.isNotEmpty
            ? FloatingActionButton(
                onPressed: _deleteSelectedContacts,
                backgroundColor: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              )
            : null,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color.fromARGB(255, 240, 230, 240),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
    );
  }

  Widget _buildSelectAllCheckbox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _selectAll,
              onChanged: (value) {
                setState(() {
                  _selectAll = value ?? false;
                  for (var contact in _contacts) {
                    contact['isSelected'] = _selectAll;
                  }
                });
              },
            ),
            const Text('Select All'),
          ],
        ),
        TextButton(
          onPressed: () {
            setState(() {
              for (var contact in _contacts) {
                contact['isSelected'] = false;
              }
              _isDeleteMode = false;
              _selectAll = false;
            });
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildContactsList() {
    List<Map<String, dynamic>> filteredContacts = _contacts.where((contact) {
      String name = contact['name'] ?? '';
      String phone = contact['phoneNumber'] ?? '';
      return name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          phone.contains(_searchQuery);
    }).toList();

    if (filteredContacts.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            'No contacts found.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: filteredContacts.length,
        itemBuilder: (context, index) {
          String name = filteredContacts[index]['name'] ?? '';
          String phone = filteredContacts[index]['phoneNumber'] ?? '';
          String imageUrl = filteredContacts[index]['imageUrl'] ?? '';
          bool isSelected = filteredContacts[index]['isSelected'] ?? false;

          return ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isDeleteMode)
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        filteredContacts[index]['isSelected'] = value ?? false;
                      });
                    },
                  ),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactProfileScreen(
                          contact: filteredContacts[index],
                        ),
                      ),
                    );
                    _fetchContacts(); // Refresh contacts after returning
                  },
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : const AssetImage('assets/icon.jpg') as ImageProvider,
                  ),
                ),
              ],
            ),
            title: Text(name),
            subtitle: Text(phone),
            trailing: IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () async {
                // Place call using the global `ongoingCalls` collection
                try {
                  // Check if the recipient exists
                  QuerySnapshot userQuery = await FirebaseFirestore.instance
                      .collection('users')
                      .where('user_details.phoneNumber', isEqualTo: phone)
                      .limit(1)
                      .get();

                  if (userQuery.docs.isNotEmpty) {
                    String recipientUid = userQuery.docs.first.id;
                    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

                    // Create a new call in `ongoingCalls`
                    String callId = FirebaseFirestore.instance.collection('ongoingCalls').doc().id;

                    await FirebaseFirestore.instance.collection('ongoingCalls').doc(callId).set({
                      'callerUid': currentUserUid,
                      'callerPhoneNumber': phone,
                      'acceptorUid': recipientUid,
                      'acceptorPhoneNumber': phone,
                      'callId': callId,
                      'status': 'placed',
                      'timestamp': FieldValue.serverTimestamp(),
                    });

                    // Navigate to the AudioCallingScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AudioCallingScreen(
                          enteredNumber: phone,
                          recipientUid: recipientUid,
                          callId: callId,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('User with this phone number does not exist.')),
                    );
                  }
                } catch (e) {
                  print('Error initiating call: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to place the call.')),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteSelectedContacts() async {
    if (!_contacts.any((contact) => contact['isSelected'])) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No contacts selected to delete')),
      );
      return;
    }

    try {
      String userId = _auth.currentUser?.uid ?? '';
      DocumentReference userDoc = _firestore.collection('users').doc(userId);

      List<Map<String, dynamic>> remainingContacts = _contacts
          .where((contact) => !contact['isSelected'])
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      await userDoc.update({
        'contacts': remainingContacts,
      });

      setState(() {
        _contacts = remainingContacts;
        _isDeleteMode = false;
        _selectAll = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected contacts deleted')),
      );
    } catch (e) {
      print('Error deleting contacts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete contacts')),
      );
    }
  }

  void _showPopupMenu(BuildContext context) async {
    await showMenu(
      color: const Color.fromARGB(255, 39, 196, 159),
      context: context,
      position: const RelativeRect.fromLTRB(300, 80, 0, 0),
      items: [
        const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
        const PopupMenuItem<String>(value: 'profile', child: Text('Profile')),
        const PopupMenuItem<String>(
            value: 'translations', child: Text('Translations')),
      ],
      elevation: 8.0,
    ).then((value) {
      switch (value) {
        case 'delete':
          if (_contacts.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No contacts to delete')),
            );
          } else {
            setState(() {
              _isDeleteMode = true;
            });
          }
          break;
        case 'profile':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
          break;
        // case 'translations':
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => const TranslationsScreen()),
        //   );
        //   break;
      }
    });
  }
}
