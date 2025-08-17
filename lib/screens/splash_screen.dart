import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ToDoList/bloc/auth/auth_bloc.dart';
import 'package:ToDoList/bloc/auth/auth_event.dart';
import 'package:ToDoList/bloc/auth/auth_state.dart';
import 'package:ToDoList/screens/register.dart';
import 'package:ToDoList/screens/admin_screen.dart';
import 'package:ToDoList/screens/task_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(CheckAuthStatusEvent());
    });
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
                MaterialPageRoute(builder: (context) => TaskPage()),
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
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.business, size: 50, color: Colors.white),
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
