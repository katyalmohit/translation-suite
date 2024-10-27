import 'package:flutter/material.dart';
import 'package:voicecall/screens/keypad_screen.dart';
import 'package:voicecall/screens/recent_screen.dart';
import 'package:voicecall/screens/contacts_screen.dart';

// List of screens for the bottom navigation
List<Widget> homeScreenItems = [
  const KeypadScreen(),
  const RecentScreen(),
  const ContactsScreen(),
];
