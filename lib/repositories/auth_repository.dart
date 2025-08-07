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
      }
    } on FirebaseAuthException catch (_) {
    } catch (_) {}
    return UserModel(role: role, email: email, password: password);
  }

  Future<UserModel> loginAsEmailPassword(String email, String password) async {
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
          return UserModel(role: "admin", email: email, password: password);
        }

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        if (userDoc.exists) {
          return UserModel(role: "user", email: email, password: password);
        }
        throw Exception("User not found in the database");
      } else {
        throw Exception("Failed to get user ID");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception("No user found with this email");
      } else if (e.code == 'wrong-password') {
        throw Exception("Wrong password");
      } else {
        throw Exception(e.message ?? "Login failed");
      }
    } catch (e) {
      throw Exception("An unexpected error occurred during login");
    }
  }

  Future<void> signOut() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      auth.signOut();
    } on FirebaseAuthException catch (_) {
      // Handle error silently
    }
  }

  Future<UserModel?> getCurrentUserWithRole(String uid) async {
    try {
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(uid)
          .get();
      if (adminDoc.exists) {
        Map<String, dynamic> data = adminDoc.data() as Map<String, dynamic>;
        String email = data['email'] ?? "";
        if (email.isEmpty) {
          email = FirebaseAuth.instance.currentUser?.email ?? "";
        }
        return UserModel(role: "admin", email: email, password: "");
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        String email = data['email'] ?? "";
        if (email.isEmpty) {
          email = FirebaseAuth.instance.currentUser?.email ?? "";
        }
        return UserModel(role: "user", email: email, password: "");
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}
