import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class IncomingCallScreen extends StatelessWidget {
  final Map<String, dynamic> callData;
  final String callId;

  const IncomingCallScreen({Key? key, required this.callData, required this.callId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String callerPhoneNumber = callData['callerPhoneNumber'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incoming Call'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Incoming call from: $callerPhoneNumber',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  onPressed: () async {
                    // Accept the call: update status
                    await FirebaseFirestore.instance
                        .collection('ongoingCalls')
                        .doc(callId)
                        .update({'status': 'ongoing'});

                    // Navigate to Zego Call Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ZegoUIKitPrebuiltCall(
                          appID: 199803229, // Replace with your Zego App ID
                          appSign: "e257121ab70ee97d0fdaf2ae55258eaab6b37104cddda4ccde79206080d933db", // Replace with your App Sign
                          userID: callData['acceptorUid'],
                          callID: callId,
                          config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
                            // ..onOnlySelfInRoom = (context) {
                            //   Navigator.pop(context);
                            // }, /// support minimizing
          ..topMenuBar.isVisible = true
          ..topMenuBar.buttons = [
            ZegoCallMenuBarButtonName.minimizingButton,
            ZegoCallMenuBarButtonName.showMemberListButton,
            ZegoCallMenuBarButtonName.soundEffectButton,
          ],
                          userName: 'Acceptor',
                        ),
                      ),
                    );
                  },
                  child: const Text('Accept'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  onPressed: () async {
                    // Decline the call: update status
                    await FirebaseFirestore.instance
                        .collection('ongoingCalls')
                        .doc(callId)
                        .update({'status': 'declined'});

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Call declined')),
                    );

                    Navigator.pop(context);
                  },
                  child: const Text('Decline'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// extension on ZegoUIKitPrebuiltCallConfig {
//   set onOnlySelfInRoom(Null Function(dynamic context) onOnlySelfInRoom) {}
// }
