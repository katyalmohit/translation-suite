import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago; // Import the timeago package
import 'package:voicecall/screens/profile_screen.dart';
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

      // Fetch recent calls from the user's callLogs
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      var userData = userDoc.data() as Map<String, dynamic>;
      List<dynamic> callLogs = userData['callLogs'] ?? [];

      List<Map<String, dynamic>> fetchedRecentContacts = [];

      for (var callLog in callLogs) {
        String dialedNumber = callLog['phoneNumber'] ?? 'Unknown';

        // Check if the dialed number exists in the user's contacts
        var contact = (userData['contacts'] ?? []).firstWhere(
          (contact) => contact['phone'] == dialedNumber,
          orElse: () => null,
        );

        String name = contact != null ? contact['name'] ?? 'Unknown' : 'Unknown';

        fetchedRecentContacts.add({
          'name': name,
          'number': dialedNumber,
          'status': callLog['status'] ?? 'Unknown',
          'timestamp': callLog['timestamp'] ?? '',
          'isSelected': false,
        });
      }

      setState(() {
        recentContacts = fetchedRecentContacts;
        _isLoading = false;
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
        floatingActionButton: _isDeleteMode &&
                recentContacts.any((contact) => contact['isSelected'])
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
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
        ),
        TextButton(
          onPressed: () {
            setState(() {
              for (var contact in recentContacts) {
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

  Widget _buildRecentContactsList() {
    List<Map<String, dynamic>> filteredContacts = recentContacts.where((contact) {
      String name = contact['name']?.toLowerCase() ?? '';
      String number = contact['number'] ?? '';
      return name.contains(_searchQuery.toLowerCase()) || number.contains(_searchQuery);
    }).toList();

    if (filteredContacts.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text("No contacts found."),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: filteredContacts.length,
        itemBuilder: (context, index) {
          String name = filteredContacts[index]['name'] ?? 'Unknown';
          String number = filteredContacts[index]['number'] ?? '';
          String status = filteredContacts[index]['status'];
          Timestamp timestamp = filteredContacts[index]['timestamp'];

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/icon.jpg'), // Default image
            ),
            title: Text(name),
            subtitle: Text('$number\n${timeago.format(timestamp.toDate())}'), // Format the timestamp using timeago
            trailing: Icon(
              status == 'accepted' ? Icons.call_received : Icons.call_made,
              color: status == 'accepted' ? Colors.green : Colors.blue,
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteSelectedContacts() async {
    if (!recentContacts.any((contact) => contact['isSelected'])) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No recent contacts to delete')),
      );
      return;
    }

    // Show a "deleting contacts" snackbar before starting the delete operation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deleting selected contacts...')),
    );

    try {
      for (var contact in recentContacts.where((c) => c['isSelected'])) {
        await _firestore.collection('users').doc(userId).update({
          'callLogs': FieldValue.arrayRemove([contact]),
        });
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
      }
    });
  }
}