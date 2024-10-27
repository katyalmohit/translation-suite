// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class CallScreen extends StatefulWidget {
//   final String callId;
//   final bool isCaller;

//   const CallScreen({super.key, required this.callId, required this.isCaller});

//   @override
//   State<CallScreen> createState() => _CallScreenState();
// }

// class _CallScreenState extends State<CallScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   late RTCPeerConnection _peerConnection;
//   final _localRenderer = RTCVideoRenderer();
//   final _remoteRenderer = RTCVideoRenderer();

//   @override
//   void initState() {
//     super.initState();
//     _initRenderers();
//     _initializeWebRTC();
//   }

//   Future<void> _initRenderers() async {
//     await _localRenderer.initialize();
//     await _remoteRenderer.initialize();
//   }

//   Future<void> _initializeWebRTC() async {
//     // Initialize peer connection
//     _peerConnection = await createPeerConnection({
//       'iceServers': [
//         {'urls': 'stun:stun.l.google.com:19302'}
//       ]
//     });

//     _peerConnection.onTrack = (event) {
//       if (event.track.kind == 'video') {
//         _remoteRenderer.srcObject = event.streams[0];
//       }
//     };

//     if (widget.isCaller) {
//       // Caller creates offer
//       RTCSessionDescription offer = await _peerConnection.createOffer();
//       await _peerConnection.setLocalDescription(offer);
//       _sendSignal('offer', offer.sdp!);
//     } else {
//       // Callee waits for offer
//       _firestore.collection('calls').doc(widget.callId).snapshots().listen((doc) async {
//         if (doc.exists && doc['type'] == 'offer') {
//           RTCSessionDescription offer = RTCSessionDescription(doc['sdp'], 'offer');
//           await _peerConnection.setRemoteDescription(offer);

//           // Create answer
//           RTCSessionDescription answer = await _peerConnection.createAnswer();
//           await _peerConnection.setLocalDescription(answer);
//           _sendSignal('answer', answer.sdp!);
//         }
//       });
//     }
//   }

//   Future<void> _sendSignal(String type, String sdp) async {
//     await _firestore.collection('calls').doc(widget.callId).set({
//       'type': type,
//       'sdp': sdp,
//     });
//   }

//   @override
//   void dispose() {
//     _localRenderer.dispose();
//     _remoteRenderer.dispose();
//     _peerConnection.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Call in Progress'),
//         backgroundColor: Colors.blue,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.call_end, color: Colors.red),
//             onPressed: () {
//               Navigator.pop(context); // End the call
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(child: RTCVideoView(_localRenderer)),
//           Expanded(child: RTCVideoView(_remoteRenderer)),
//         ],
//       ),
//     );
//   }
// }
