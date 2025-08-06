import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intern01/bloc/auth/auth_bloc.dart';
import 'package:intern01/bloc/auth/auth_event.dart';
import 'package:intern01/bloc/auth/auth_state.dart';
import 'package:intern01/screens/register.dart';
import 'package:intern01/screens/admin_screen.dart';
import 'package:intern01/screens/user_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(CheckAuthStatusEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            if (state.role == "admin") {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => AdminScreen()),
              );
            } else if (state.role == "user") {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => UserScreen()),
              );
            }
          } else if (state is AuthError || state is AuthInitial) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Register()),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.black,
                      backgroundColor: Colors.grey[300],
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Loading...',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    "https://www.freepik.com/free-vector/branding-identity-corporate-wellness-vector-logo-design_28699649.htm#fromView=keyword&page=1&position=0&uuid=e9f096f2-5fa9-4ea9-abcb-5f4f6fcb20bc&query=Health+Wellness+Logo",
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(
                    color: Colors.black,
                    backgroundColor: Colors.grey[300],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
