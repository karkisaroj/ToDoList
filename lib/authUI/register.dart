import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    MediaQueryData querySize = MediaQuery.of(context);
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: Text("Register UI"), centerTitle: true),
      body: Column(
        children: [
          SizedBox(height: 100.h),
          Padding(
            padding: EdgeInsetsGeometry.all(50),
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
            padding: EdgeInsetsGeometry.all(50),
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
          SizedBox(height: 50.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  log("Email is: ${emailController.toString()}");
                },
                child: Text("Enter as admin"),
              ),
              SizedBox(width: 30.w),
              ElevatedButton(onPressed: () {}, child: Text("Enter as a user")),
            ],
          ),
        ],
      ),
    );
  }
}
