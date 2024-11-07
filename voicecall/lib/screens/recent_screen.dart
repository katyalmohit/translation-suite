import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voicecall/screens/profile_screen.dart';
import 'package:voicecall/translations/translation_screen.dart';
import '../widgets/custom_app_bar.dart';

class RecentScreen extends StatefulWidget {
  const RecentScreen({super.key});

  @override
  State<RecentScreen> createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  bool _isLoading = true; // Track loading state
  bool _isDeleteMode = false;
  bool _selectAll = false;
  String _searchQuery = '';
  List<Map<String, dynamic>> recentContacts = [];

  @override
  void initState() {
    super.initState();
    _fetchRecentCalls();
  }

  // Fetch recent calls and display in the UI
  Future<void> _fetchRecentCalls() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (userId == null) {
        print('User is not logged in.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User is not logged in.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final recentCallsSnapshot = await _firestore
          .collection('recents')
          .where('userId', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> fetchedRecentContacts = [];

      for (var doc in recentCallsSnapshot.docs) {
        Map<String, dynamic> recentCallData = doc.data();
        String calledNumber = recentCallData['calledNumber'] ?? 'Unknown';

        // Check if contact exists in the current user's 'contacts' collection
        final contactSnapshot = await _firestore
            .collection('contacts')
            .where('userId', isEqualTo: userId) // Filter by current user
            .where('phone', isEqualTo: calledNumber)
            .limit(1)
            .get();

        if (contactSnapshot.docs.isNotEmpty) {
          var contactData = contactSnapshot.docs.first.data();
          fetchedRecentContacts.add({
            'id': doc.id, // Firebase document ID for deletion
            'name': contactData['name'] ?? 'Unknown',
            'number': calledNumber,
            'imageUrl': contactData['imageUrl'] ?? '',
            'status': recentCallData['status'] ?? 'placed',
            'isSelected': false,
          });
        } else {
          fetchedRecentContacts.add({
            'id': doc.id,
            'name': 'Unknown',
            'number': calledNumber,
            'imageUrl': '',
            'status': recentCallData['status'] ?? 'placed',
            'isSelected': false,
          });
        }
      }

      setState(() {
        recentContacts = fetchedRecentContacts;
        _isLoading = false; // Set loading state to false once data is fetched
      });
    } catch (e) {
      print('Error fetching recent calls: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load recent calls')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Recent Calls",
          onMorePressed: () => _showPopupMenu(context),
        ),
        body: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text("Fetching recent calls...")
                  ],
                ),
              )
            : Column(
                children: [
                  const SizedBox(height: 10),
                  _buildSearchBar(),
                  if (_isDeleteMode) _buildSelectAllCheckbox(),
                  _buildRecentContactsList(),
                ],
              ),
              floatingActionButton: _isDeleteMode && recentContacts.any((contact) => contact['isSelected'])
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
          hintText: "Search Recent Calls",
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
              for (var contact in recentContacts) {
                contact['isSelected'] = _selectAll;
              }
            });
          },
        ),
        const Text('Select All'),
      ],
    );
  }

  Widget _buildRecentContactsList() {
    if (recentContacts.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text("No recent contacts."),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: recentContacts.length,
        itemBuilder: (context, index) {
          String name = recentContacts[index]['name'] ?? 'Unknown';
          String number = recentContacts[index]['number'] ?? '';
          String imageUrl = recentContacts[index]['imageUrl'] ?? '';
          bool isSelected = recentContacts[index]['isSelected'] ?? false;
          String status = recentContacts[index]['status'];

          if (_searchQuery.isNotEmpty &&
              !name.toLowerCase().contains(_searchQuery.toLowerCase())) {
            return Container();
          }

          return ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isDeleteMode)
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        recentContacts[index]['isSelected'] = value ?? false;
                        _selectAll = recentContacts.every((contact) => contact['isSelected']);
                      });
                    },
                  ),
                CircleAvatar(
                  radius: 25,
                  backgroundImage: imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : const AssetImage('assets/icon.jpg') as ImageProvider,
                ),
              ],
            ),
            title: Text(name),
            subtitle: Text(number),
            trailing: Icon(
              status == 'accepted' ? Icons.call_received : Icons.call_made,
              color: status == 'accepted' ? Colors.green : Colors.blue,
            ),
            onTap: () {
              print('Call details for $name');
            },
          );
        },
      ),
    );
  }

  // Delete selected recent calls from both the UI and Firebase
  Future<void> _deleteSelectedContacts() async {
    if (!recentContacts.any((contact) => contact['isSelected'])) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No recent contacts to delete')),
      );
      return;
    }
    
      // Show a SnackBar to indicate the deletion process
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Deleting contact(s)...')),
  );

    try {
      for (var contact in recentContacts.where((c) => c['isSelected'])) {
        await _firestore.collection('recents').doc(contact['id']).delete();
      }

      setState(() {
        recentContacts.removeWhere((contact) => contact['isSelected']);
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
        const PopupMenuItem<String>(value: 'translations', child: Text('Translations')),
      ],
      elevation: 8.0,
    ).then((value) {
      switch (value) {
        case 'delete':
          if (recentContacts.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No recent contacts to delete')),
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
