import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intern01/bloc/auth/auth_bloc.dart';
import 'package:intern01/bloc/auth/auth_state.dart';
import 'package:intern01/bloc/image/image_bloc.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  String? currentEmail;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void desposeState() {
    super.dispose();
    _descriptionController.dispose();
  }

  void _loadUserData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      context.read<ImageBloc>().add(LoadUserImageEvent(authState.email));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {},
        child: BlocListener<ImageBloc, ImageState>(
          listener: (context, imageState) {},
          child: SafeArea(child: SingleChildScrollView()),
        ),
      ),
    );
  }
}
