import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn? _googleSignIn = kIsWeb ? null : GoogleSignIn();

  // Google Sign-In
  // if ang signin kay Google kay gi click nako ang pangalan nako kay mag login siya. else, mangita siyag credential niya -sir velez
  Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      UserCredential userCredential = 
        await _auth.signInWithPopup(googleProvider);
      return userCredential.user;
    } else {
      final googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return (await _auth.signInWithCredential(credential)).user;
    }
  }

  // EMAIL/PASSWORD REGISTER
  Future<User?> registerWithEmail (String email, String password) async {
    try {
      final UserCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return UserCredential.user; // if okay siya hehe
    } catch (e) {
      print("Registration Error: $e");
      return null;
    }
  }

  // EMAIL/PASSWORD LOGIN
  Future <User?> signInWithEmail (String email, String password) async {
    try {
      final UserCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return UserCredential.user;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // SIGN OUT
  Future <void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn?.signOut();
    }
    await _auth.signOut();
  }

    // FORGOT PASSWORD
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // null = success
    } catch (e) {
      print("Reset Password Error: $e");
      return e.toString();
    }
  }

  Stream <User?> get userStream => _auth.authStateChanges();
}