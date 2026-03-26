import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Email/Password Sign Up
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e.code);
      if (kDebugMode) print('Signup error: ${e.code}');
      rethrow;
    }
  }

  // Email/Password Login
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e.code);
      if (kDebugMode) print('Login error: ${e.code}');
      rethrow;
    }
  }

  // Google Sign In
  Future<User?> googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e.code);
      if (kDebugMode) print('Google login error: ${e.code}');
      rethrow;
    } catch (e) {
      if (kDebugMode) print('Google sign in error: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Error handling
  String _handleAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        throw Exception('Invalid email address.');
      case 'user-disabled':
        throw Exception('This user account has been disabled.');
      case 'user-not-found':
        throw Exception('No user found for that email.');
      case 'wrong-password':
        throw Exception('Wrong password provided.');
      case 'email-already-in-use':
        throw Exception('The account already exists.');
      case 'weak-password':
        throw Exception('The password provided is too weak.');
      case 'operation-not-allowed':
        throw Exception('Operation is not allowed.');
      case 'account-exists-with-different-credential':
        throw Exception('Account exists with different credential.');
      default:
        throw Exception('An undefined error occurred.');
    }
  }

  // Current user
  User? get currentUser => _auth.currentUser;

  // Stream user changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
