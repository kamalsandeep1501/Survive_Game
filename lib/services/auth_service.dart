import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  int _highScore = 0;
  int get highScore => _highScore;

  String? _username;
  String? get username => _username;

  AuthService() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _fetchUserData(user.uid);
      } else {
        _highScore = 0;
        _username = null;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _highScore = doc.data()?['highScore'] ?? 0;
        _username = doc.data()?['username'];
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  Future<String?> signUp(String email, String password, String inputUsername) async {
    try {
      // Check if username is taken
      final usernameDoc = await _firestore.collection('usernames').doc(inputUsername).get();
      if (usernameDoc.exists) {
        return "Username already taken.";
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // Save user profile
      await _firestore.collection('users').doc(uid).set({
        'username': inputUsername,
        'email': email,
        'highScore': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastPlayed': FieldValue.serverTimestamp(),
      });

      // Reserve username
      await _firestore.collection('usernames').doc(inputUsername).set({
        'uid': uid,
      });

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> updateHighScore(int newScore) async {
    if (!isLoggedIn) return;
    if (newScore > _highScore) {
      _highScore = newScore;
      notifyListeners();

      try {
        await _firestore.collection('users').doc(currentUser!.uid).update({
          'highScore': newScore,
          'lastPlayed': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint("Failed to update high score: $e");
      }
    }
  }
}
