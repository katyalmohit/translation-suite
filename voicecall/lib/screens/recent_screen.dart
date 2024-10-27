import 'package:flutter/material.dart';
import 'package:voicecall/layout/mobile_layout.dart';
import 'package:voicecall/screens/profile_screen.dart';
import 'package:voicecall/translations/translation_screen.dart';
import 'package:voicecall/widgets/custom_app_bar.dart';

class RecentScreen extends StatefulWidget {
  const RecentScreen({super.key});

  @override
  State<RecentScreen> createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen> {
  final List<Map<String, dynamic>> recentContacts = [
    {'name': 'Mr. Rohan Kumar', 'number': '+99897 565 71 73', 'isSelected': false},
    {'name': 'Mr. Amit Sharma', 'number': '+99897 565 71 73', 'isSelected': false},
    {'name': 'Mr. Anshul Goyal', 'number': '+99897 565 71 73', 'isSelected': false},
  ];

  bool _isDeleteMode = false;
  bool _selectAll = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Recent Calls",
          onMorePressed: () => _showPopupMenu(context),
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),
            _buildSearchBar(),
            if (_isDeleteMode) _buildSelectAllCheckbox(),
            _buildRecentContactsList(),
          ],
        ),
        floatingActionButton: _isDeleteMode
            ? FloatingActionButton(
                onPressed: _deleteSelectedContacts,
                backgroundColor: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              )
            : null,
        bottomNavigationBar: null, // Handled by MobileScreenLayout
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
    return Expanded(
      child: ListView.builder(
        itemCount: recentContacts.length,
        itemBuilder: (context, index) {
          String name = recentContacts[index]['name'] ?? '';
          String number = recentContacts[index]['number'] ?? '';
          bool isSelected = recentContacts[index]['isSelected'] ?? false;

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
                const CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage('assets/icon.jpg'),
                ),
              ],
            ),
            title: Text(name),
            subtitle: Text(number),
            trailing: IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () {
                print('Calling $name');
              },
            ),
          );
        },
      ),
    );
  }

  void _deleteSelectedContacts() {
    setState(() {
      recentContacts.removeWhere((contact) => contact['isSelected']);
      _isDeleteMode = false; // Exit delete mode after deletion
      _selectAll = false; // Reset select-all state
    });
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
            _isDeleteMode = true; // Enter delete mode
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
