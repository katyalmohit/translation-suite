import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class AudioCallingScreen extends StatefulWidget {
  final String enteredNumber;
  final String recipientUid;
  final String callId;

  const AudioCallingScreen({
    Key? key,
    required this.enteredNumber,
    required this.recipientUid,
    required this.callId,
  }) : super(key: key);

  @override
  _AudioCallingScreenState createState() => _AudioCallingScreenState();
}

class _AudioCallingScreenState extends State<AudioCallingScreen> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _initializeUserId();
    _navigateToCall();
  }

  // Initialize the user ID
  void _initializeUserId() {
    final user = FirebaseAuth.instance.currentUser;
    userId = user?.uid;
  }

  // Automatically navigate to the actual call screen
  void _navigateToCall() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AudioCallingPage(callId: widget.callId),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connecting Call'),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class AudioCallingPage extends StatelessWidget {
  final String callId;

  const AudioCallingPage({Key? key, required this.callId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      body: SafeArea(
        child: ZegoUIKitPrebuiltCall(
          appID: 199803229, // Replace with your ZegoCloud App ID
          appSign: "e257121ab70ee97d0fdaf2ae55258eaab6b37104cddda4ccde79206080d933db", // Replace with your App Sign
          userID: userId,
          callID: callId,
          config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
            ..topMenuBar.isVisible = true
            ..topMenuBar.buttons = [
              ZegoCallMenuBarButtonName.minimizingButton,
              ZegoCallMenuBarButtonName.showMemberListButton,
              ZegoCallMenuBarButtonName.soundEffectButton,
            ],
          userName: 'User',
        ),
      ),
    );
  }
}
