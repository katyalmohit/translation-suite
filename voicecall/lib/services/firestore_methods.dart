import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voicecall/models/user.dart' as AppUserModel; // Alias for clarity

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserData(AppUserModel.User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      print('Failed to save user data: $e');
      rethrow; // Rethrow to catch the error in the UI layer
    }
  }

  Future<AppUserModel.User?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUserModel.User.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return null;
  }
}

