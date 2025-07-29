import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intern01/authUI/register.dart';
import 'package:intern01/screen/admin_screen.dart';
import 'package:intern01/screen/user_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<String?> _getUserRole(String uid) async {
    DocumentSnapshot adminDoc = await FirebaseFirestore.instance
        .collection('admins')
        .doc(uid)
        .get();
    if (adminDoc.exists) {
      Map<String, dynamic> data = adminDoc.data() as Map<String, dynamic>;
      return data['role'];
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (userDoc.exists) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      return data['role'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(
              color: Colors.black,
              backgroundColor: Colors.white,
            );
          }
          if (snapshot.hasData) {
            return FutureBuilder(
              future: _getUserRole(snapshot.data!.uid),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (roleSnapshot.data == "admin") {
                  return AdminScreen();
                } else if (roleSnapshot.data == "user") {
                  return UserScreen();
                } else {
                  return Register();
                }
              },
            );
          }
          return Register();
        },
      ),
    );
  }
}
