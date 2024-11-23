import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'dart:math' as math;


class AudioCallingScreen extends StatefulWidget {
  final String enteredNumber;
  const AudioCallingScreen({Key? key, required this.enteredNumber}) : super(key: key);

  @override
  _AudioCallingScreenState createState() => _AudioCallingScreenState();
}

class _AudioCallingScreenState extends State<AudioCallingScreen> {
  String? userId;
  String? currentUserPhoneNumber;
  bool isLoading = true;
  String callId = "";
  final TextEditingController secretKeyController = TextEditingController();
  bool isPlacingCall = false;
  String callStatus = "";

  @override
  void initState() {
    super.initState();
    _initializeUserId();
    _fetchCurrentUserPhoneNumber();
  }

  void _initializeUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
    } else {
      userId = math.Random().nextInt(10000).toString();
    }
  }

  Future<void> _fetchCurrentUserPhoneNumber() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          currentUserPhoneNumber = doc['phoneNumber'];
          isLoading = false;
        });
      }
    }
  }

  void _generateCallId() {
    setState(() {
      callId = (math.Random().nextInt(900000) + 100000).toString();
    });
  }

  Future<void> _saveCallDetailsToFirebase(String callId, String status) async {
    try {
      await FirebaseFirestore.instance.collection('recents').add({
        'userId': userId,
        'calledNumber': widget.enteredNumber,
        'callId': callId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': status,
      });
    } catch (e) {
      print("Error saving call details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Call'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: isPlacingCall ? _buildPlacingCallScreen() : _buildCallOptionScreen(),
            ),
    );
  }

  // Screen to choose between "Place Call" and "Accept Call"
  Widget _buildCallOptionScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Choose an option:",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // Place Call Button - Generates a new call ID and initiates the call without checks
        ElevatedButton(
          onPressed: () {
            _generateCallId();
            setState(() {
              isPlacingCall = true;
              callStatus = 'placed';
            });
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            backgroundColor: Colors.green,
          ),
          child: const Text(
            'Place Call',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),

        const SizedBox(height: 20),

        // Accept Call Button - Asks for Call ID, checks Firebase, and joins if valid
        ElevatedButton(
          onPressed: () {
            setState(() {
              isPlacingCall = true;
              callStatus = 'accepted';
            });
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            backgroundColor: Colors.blue,
          ),
          child: const Text(
            'Accept Call',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // Screen that shows the call ID, accepts a secret key if needed, and proceeds to the call
  Widget _buildPlacingCallScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Calling Number: ${widget.enteredNumber}',
          style: TextStyle(fontSize: 20, color: Colors.grey[700]),
        ),
        const SizedBox(height: 20),
        if (callId.isNotEmpty) ...[
          const Text(
            'Generated Call ID (share with others):',
            style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 22, 19, 19)),
          ),
          const SizedBox(height: 8),
          Text(
            callId,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 20),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: TextField(
            controller: secretKeyController,
            decoration: InputDecoration(
              labelText: 'Enter Secret Key',
              labelStyle: TextStyle(color: Colors.grey[700]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              filled: true,
              fillColor: Colors.grey[200],
              prefixIcon: Icon(Icons.key, color: Colors.grey[700]),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(height: 20),
        // Button to validate and start call without Firebase check for "Place Call"
        ElevatedButton(
          onPressed: () async {
            String enteredCallId = secretKeyController.text.trim();

            // Validate that the entered call ID matches the generated call ID for Place Call
            if (callStatus == 'placed') {
              if (enteredCallId != callId) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid secret key. Please enter the correct key.')),
                );
                return;
              }

              _saveCallDetailsToFirebase(callId, 'placed');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AudioCallingPage(callingId: callId),
                ),
              );
            } else if (callStatus == 'accepted') {
              // Accept Call logic - Check Firebase if call ID exists
              if (enteredCallId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter the call ID to proceed.')),
                );
                return;
              }

              final callDoc = await FirebaseFirestore.instance
                  .collection('recents')
                  .where('callId', isEqualTo: enteredCallId)
                  .limit(1)
                  .get();

              if (callDoc.docs.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid Call ID. Please try again.')),
                );
                return;
              }

              await _saveCallDetailsToFirebase(enteredCallId, 'accepted');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AudioCallingPage(callingId: enteredCallId),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            backgroundColor: Colors.green,
          ),
          child: const Text(
            'Start Call',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class AudioCallingPage extends StatelessWidget {
  final String callingId;
  const AudioCallingPage({Key? key, required this.callingId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      body: SafeArea(
        child: ZegoUIKitPrebuiltCall(
          appID: 199803229,
          appSign: "e257121ab70ee97d0fdaf2ae55258eaab6b37104cddda4ccde79206080d933db",
          userID: userId,
          callID: callingId,
          config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
            ..onOnlySelfInRoom = (context) {
              Navigator.pop(context);
            },
          userName: 'User',
        ),
      ),
    );
  }
}

extension on ZegoUIKitPrebuiltCallConfig {
  set onOnlySelfInRoom(Null Function(dynamic context) onOnlySelfInRoom) {}
}
