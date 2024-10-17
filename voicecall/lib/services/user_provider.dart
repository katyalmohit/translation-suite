// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:voicecall/models/user.dart';

// class FirestoreMethods {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> saveUserData(User user) async {
//     await _firestore.collection('users').doc(user.uid).set(user.toMap());
//   }

//   Future<User?> getUserData(String uid) async {
//     DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
//     if (doc.exists) {
//       return User.fromMap(doc.data() as Map<String, dynamic>);
//     }
//     return null;
//   }
// }
