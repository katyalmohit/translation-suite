import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:voicecall/firebase/firebase_options.dart';
import 'package:voicecall/firebase/wrapper.dart';
import 'package:voicecall/services/call_listener_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Call',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Builder(
        builder: (context) {
          // Initialize Call Listener Service globally
          CallListenerService.initializeListener(context);
          return const Wrapper(); // Use Wrapper for auth handling
        },
      ),
    );
  }
}
