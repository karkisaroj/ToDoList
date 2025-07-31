import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intern01/models/user_model.dart';

class AuthCall {
  Future<UserModel?> signUpEmailPassword(
    String email,
    String password,
    String role,
  ) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      UserCredential success = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = success.user?.uid;
      if (uid != null) {
        log("User created successfully with UID: $uid");
        final userCollection = role == 'admin' ? 'admins' : 'users';
        await FirebaseFirestore.instance
            .collection(userCollection)
            .doc(uid)
            .set({
              'uid': uid,
              "email": email,
              "role": role,
              "created at": Timestamp.now(),
            });
        log("User data saved to Firestore successfully");
        return null;
      } else {
        log("Failed to get user ID after registration");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        log("The password provided is too weak.");
      } else if (e.code == 'email-already-in-use') {
        log("The account already exists for that email.");
      } else {
        log("Firebase Auth Error: ${e.message}");
      }
    } catch (e) {
      log("Unexpected error: $e");
    }
    return null;
  }

  Future<UserModel?> loginAsEmailPassword(String email, String password) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      UserCredential success = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = success.user?.uid;
      if (uid != null) {
        log("Login successful, checking role...");

        DocumentSnapshot adminDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(uid)
            .get();
        if (adminDoc.exists) {
          log("Admin found");
          return UserModel(role: "admin", email: email, password: password);
        }

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        if (userDoc.exists) {
          log("User found");
          return UserModel(role: "user", email: email, password: password);
        }
      } else {
        log("Failed");
      }
    } on FirebaseAuthException catch (e) {
      log("Firebase Auth Error: ${e.code}");
      if (e.code == 'user-not-found') {
        log("No user found with this email");
      } else if (e.code == 'wrong-password') {
        log("Wrong password");
      } else {
        log(e.message ?? "Login failed");
      }
    } catch (e) {
      log("Unexpected login error: $e");
      log("An unexpected error occurred");
    }
    return null;
  }

  Future<void> signOut() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      auth.signOut();
    } on FirebaseAuthException catch (e) {
      log("Error $e");
    }
  }
}
