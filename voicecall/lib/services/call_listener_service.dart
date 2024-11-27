import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:voicecall/screens/incoming_call_screen.dart';

class CallListenerService {
  static void initializeListener(BuildContext context) {
    String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserUid != null) {
      FirebaseFirestore.instance
          .collection('ongoingCalls')
          .where('acceptorUid', isEqualTo: currentUserUid)
          .where('status', isEqualTo: 'placed')
          .snapshots()
          .listen((snapshot) {
        for (var doc in snapshot.docs) {
          // Trigger vibration for incoming call
          _triggerVibration();

          // Navigate to IncomingCallScreen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => IncomingCallScreen(callData: doc.data(), callId: doc.id),
            ),
          );
        }
      });
    }
  }

  static void _triggerVibration() {
    Vibration.hasVibrator().then((bool? hasVibrator) {
      if (hasVibrator == true) {
        Vibration.vibrate(pattern: [0, 500, 1000, 500, 1000], repeat: 1);
      }
    });
  }
}
