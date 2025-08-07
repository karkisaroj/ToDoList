import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthCall {
  Future<String?> signUpEmailPassword(
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
        return null;
      } else {
        return "Failed to get user ID";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return "The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        return "The account already exists for that email.";
      } else {
        return e.message;
      }
    } catch (_) {
      return "An unexpected error occurred";
    }
  }

  Future<String?> loginAsEmailPassword(String email, String password) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      UserCredential success = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = success.user?.uid;
      if (uid != null) {
        DocumentSnapshot adminDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(uid)
            .get();
        if (adminDoc.exists) {
          return "admin";
        }

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        if (userDoc.exists) {
          return "user";
        }

        return "Role not found";
      } else {
        return "Login failed";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "No user found with this email";
      } else if (e.code == 'wrong-password') {
        return "Wrong password";
      } else {
        return e.message ?? "Login failed";
      }
    } catch (_) {
      return "An unexpected error occurred";
    }
  }
}
