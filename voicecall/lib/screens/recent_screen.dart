import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

      final ongoingCallsSnapshot = await _firestore.collection('ongoingCalls').get();

      for (var doc in ongoingCallsSnapshot.docs) {
        Map<String, dynamic> callData = doc.data();
        await _logCallForUsers(callData); // Log calls for both users
      }

      // Fetch recent calls for the current user
      final recentCallsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      List<Map<String, dynamic>> fetchedRecentContacts = [];
      if (recentCallsSnapshot.exists) {
        var userData = recentCallsSnapshot.data() as Map<String, dynamic>;
        List<dynamic> callLogs = userData['callLogs'] ?? [];

        for (var callLog in callLogs) {
          fetchedRecentContacts.add({
            'name': callLog['name'] ?? 'Unknown',
            'number': callLog['phoneNumber'] ?? 'Unknown',
            'status': callLog['status'] ?? 'Unknown',
            'timestamp': callLog['timestamp'] ?? '',
            'isSelected': false,
          });
        }
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

  Future<void> _logCallForUsers(Map<String, dynamic> callData) async {
    try {
      String callerUid = callData['callerUid'] ?? '';
      String acceptorUid = callData['acceptorUid'] ?? '';
      String callerPhoneNumber = callData['callerPhoneNumber'] ?? '';
      String acceptorPhoneNumber = callData['acceptorPhoneNumber'] ?? '';
      String status = callData['status'] ?? 'Unknown';
      Timestamp timestamp = callData['timestamp'] ?? Timestamp.now();

      // Prepare call log for both users
      Map<String, dynamic> callerLog = {
        'name': 'You',
        'phoneNumber': acceptorPhoneNumber,
        'status': status,
        'timestamp': timestamp,
      };

      Map<String, dynamic> acceptorLog = {
        'name': 'Caller',
        'phoneNumber': callerPhoneNumber,
        'status': status,
        'timestamp': timestamp,
      };

      // Update caller's call logs
      await _firestore.collection('users').doc(callerUid).update({
        'callLogs': FieldValue.arrayUnion([callerLog]),
      });

      // Update acceptor's call logs
      await _firestore.collection('users').doc(acceptorUid).update({
        'callLogs': FieldValue.arrayUnion([acceptorLog]),
      });
    } catch (e) {
      print('Error logging call for users: $e');
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
      String number = contact['phoneNumber'] ?? '';
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
          String number = filteredContacts[index]['phoneNumber'] ?? '';
          String status = filteredContacts[index]['status'];
          Timestamp timestamp = filteredContacts[index]['timestamp'];

          return ListTile(
            title: Text(name),
            subtitle: Text('$number\n${timestamp.toDate()}'),
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
