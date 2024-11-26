import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => IncomingCallScreen(callData: doc.data(), callId: doc.id),
            ),
          );
        }
      });
    }
  }
}
