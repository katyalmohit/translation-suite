import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as UserModel;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up user
  Future<String> signUpUser({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String birthday,
    required String location,
  }) async {
    String result = "Some error occurred";
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          fullName.isNotEmpty &&
          phoneNumber.isNotEmpty &&
          birthday.isNotEmpty &&
          location.isNotEmpty) {
        // Create user in Firebase Auth
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Add user to Firestore
        UserModel.User user = UserModel.User(
          uid: cred.user!.uid,
          email: email,
          fullName: fullName,
          phoneNumber: phoneNumber,
          birthday: birthday,
          location: location,
        );
        await _firestore.collection('users').doc(cred.user!.uid).set(user.toJson());

        result = "success";
      } else {
        result = "Please fill all the fields";
      }
    } on FirebaseAuthException catch (e) {
      result = e.message ?? "An error occurred";
    } catch (e) {
      result = e.toString();
    }
    return result;
  }

  // Login user
  Future<String?> loginUser(String email, String password) async {
    String? result;
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        result = null; // Success
      } else {
        result = "Please enter all fields";
      }
    } on FirebaseAuthException catch (e) {
      result = e.message;
    }
    return result;
  }

  // Sign out
  Future<void> signOutUser() async {
    await _auth.signOut();
  }
}
