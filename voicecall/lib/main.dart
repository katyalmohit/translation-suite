import 'package:flutter/material.dart';
import 'package:voicecall/firebase_options.dart';
import 'package:voicecall/screens/recent_screen.dart';
import 'package:voicecall/screens/welcome_screen.dart';
import 'package:voicecall/screens/keypad_screen.dart';
import 'package:voicecall/screens/contacts_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voice Translation',
      theme: ThemeData(
        textTheme: GoogleFonts.urbanistTextTheme(),
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasData) {
                  return const WelcomeScreen(); // Authenticated users
                } else {
                  return const WelcomeScreen(); // Not authenticated
                }
              },
            ),
        '/keypad': (context) => const KeypadScreen(),
        '/recents': (context) => const RecentScreen(),
        '/contacts': (context) => const ContactsScreen(),
      },
    );
  }
}
