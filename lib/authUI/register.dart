import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intern01/repositories/auth_repository.dart';
import 'package:intern01/screens/admin_screen.dart';
import 'package:intern01/screens/user_screen.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final AuthCall _authCall = AuthCall();

  void navigate(String role) async {
    if (role == "admin") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminScreen()),
      );
    } else if (role == "user") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserScreen()),
      );
    }
  }

  void register(String role) async {
    try {
      final result = await _authCall.signUpEmailPassword(
        emailController.text,
        passwordController.text,
        role,
      );
      if (result == null) {
        log("Registration successful");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Registration successful!"),
            backgroundColor: Colors.green,
          ),
        );
        navigate(role);
      } else {
        log("Registration failed: $result");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Registration failed: $result"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      log("Unexpected error during registration: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An unexpected error occurred"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void login() async {
    try {
      final result = await _authCall.loginAsEmailPassword(
        emailController.text,
        passwordController.text,
      );

      if (result == "admin") {
        log("Admin login successful");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Welcome Admin!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminScreen()),
        );
      } else if (result == "user") {
        log("User login successful");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Welcome User!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserScreen()),
        );
      } else {
        // result contains error message
        log("Login failed: $result");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login failed: $result"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      log("Unexpected error during login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An unexpected error occurred"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData querySize = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(title: Text("Register UI"), centerTitle: true),
      body: Column(
        children: [
          SizedBox(height: 100.h),
          Padding(
            padding: const EdgeInsets.all(50),
            child: TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: "Enter your email",
                hintStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: querySize.size.width * 0.8),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(50),
            child: TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                hintText: "Enter your Password",
                hintStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: querySize.size.width * 0.8),
                ),
              ),
            ),
          ),
          SizedBox(height: 30.h),

          ElevatedButton(
            onPressed: () {
              login();
            },
            child: Text("Login"),
          ),
          SizedBox(height: 30.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  register("admin");
                },
                child: Text("Enter as admin"),
              ),
              SizedBox(width: 30.w),
              ElevatedButton(
                onPressed: () {
                  register("user");
                },
                child: Text("Enter as a user"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
