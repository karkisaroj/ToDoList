import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:intern01/bloc/auth/auth_bloc.dart';
import 'package:intern01/bloc/auth/auth_event.dart';
import 'package:intern01/bloc/auth/auth_state.dart';
import 'package:intern01/screens/admin_screen.dart';
import 'package:intern01/screens/user_screen.dart';
// You need to add this import at the top:
import 'package:flutter_bloc/flutter_bloc.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
    context.read<AuthBloc>().add(
      SignupRequested(
        email: emailController.text,
        password: passwordController.text,
        role: role,
      ),
    );
  }

  void login() async {
    context.read<AuthBloc>().add(
      LoginRequested(
        email: emailController.text,
        password: passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData querySize = MediaQuery.of(context);
    final naviation = Navigator.of(context);
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          showDialog(
            context: context,
            builder: (_) => Center(child: CircularProgressIndicator()),
          );
        } else if (state is AuthSuccess) {
          Navigator.of(context).pop();
          if (state.role == "admin") {
            naviation.push(
              MaterialPageRoute(builder: (context) => AdminScreen()),
            );
          } else {
            naviation.push(
              MaterialPageRoute(builder: (context) => UserScreen()),
            );
          }
        } else if (state is AuthError) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
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
      ),
    );
  }
}
