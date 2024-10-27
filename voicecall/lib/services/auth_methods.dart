import 'package:firebase_auth/firebase_auth.dart';
import 'package:voicecall/models/user.dart' as AppUserModel; // Alias to avoid conflict

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign Up Method
  Future<String?> signUp(
      String email, String password, AppUserModel.User user) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
      }

      return null; // If no errors, return null (success)
    } on FirebaseAuthException catch (e) {
      return e.message; // Return Firebase error message
    } catch (e) {
      return "An unknown error occurred.";
    }
  }

  // Login Method
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Successful login
    } on FirebaseAuthException catch (e) {
      return e.message; // Return Firebase error message
    } catch (e) {
      return "An unknown error occurred.";
    }
  }

  // Logout Method
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
