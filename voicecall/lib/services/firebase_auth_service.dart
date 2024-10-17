import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Login user
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Return Firebase error message
    } catch (e) {
      return "An unknown error occurred"; // General error
    }
  }

  // Sign out user
  Future<void> logout() async {
    await _auth.signOut();
  }
}
