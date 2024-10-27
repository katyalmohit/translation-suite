import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // For making phone calls
import 'package:voicecall/screens/contact_profile_screen.dart';
import 'package:voicecall/screens/profile_screen.dart';
import 'package:voicecall/translations/translation_screen.dart';
import '../layout/mobile_layout.dart';
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
  String _searchQuery = '';
  List<Map<String, dynamic>> _contacts = [];

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    try {
      String userId = _auth.currentUser?.uid ?? '';

      QuerySnapshot snapshot = await _firestore
          .collection('contacts')
          .where('userId', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> fetchedContacts = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'] ?? '',
          'phone': doc['phone'] ?? '',
          'email': doc['email'] ?? '',
          'location': doc['location'] ?? '',
          'imageUrl': doc['imageUrl'] ?? '',
          'isSelected': false,
        };
      }).toList();

      setState(() {
        _contacts = fetchedContacts;
      });
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
            _buildContactsList(),
          ],
        ),
        floatingActionButton: _isDeleteMode
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
    );
  }

Widget _buildContactsList() {
  return Expanded(
    child: ListView.builder(
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        String name = _contacts[index]['name'] ?? '';
        String phone = _contacts[index]['phone'] ?? '';
        String imageUrl = _contacts[index]['imageUrl'] ?? '';
        bool isSelected = _contacts[index]['isSelected'] ?? false;

        if (_searchQuery.isNotEmpty &&
            !name.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return Container(); // Filter results based on search query
        }

        return ListTile(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isDeleteMode) // Show checkbox in delete mode
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      _contacts[index]['isSelected'] = value ?? false;
                      _selectAll = _contacts.every((contact) => contact['isSelected']);
                    });
                  },
                ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactProfileScreen(
                        contact: _contacts[index],
                      ),
                    ),
                  );
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
            onPressed: () => _makePhoneCall(phone),
          ),
        );
      },
    ),
  );
}






  Future<void> _makePhoneCall(String phoneNumber) async {
  final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

  try {
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  } catch (e) {
    print('Error launching phone call: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not make the call')),
    );
  }
}

  Future<void> _deleteSelectedContacts() async {
    try {
      for (var contact in _contacts.where((c) => c['isSelected'])) {
        await _firestore.collection('contacts').doc(contact['id']).delete();
      }

      setState(() {
        _contacts.removeWhere((contact) => contact['isSelected']);
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
          setState(() {
            _isDeleteMode = true;
          });
          break;
        case 'profile':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
          break;
        case 'translations':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TranslationsScreen()),
          );
          break;
      }
    });
  }
}
