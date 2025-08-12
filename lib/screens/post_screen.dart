import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intern01/bloc/auth/auth_bloc.dart';
import 'package:intern01/bloc/auth/auth_state.dart';
import 'package:intern01/bloc/image_upload/image_bloc.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final ImagePicker _picker = ImagePicker();
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

  Future<void> _pickImage() async {
    final messenger = ScaffoldMessenger.of(context);
    final bloc = context.read<ImageBloc>();

    if (currentEmail == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please Login First")));
      return;
    }
    try {
      XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
      if (image != null) {
        final selectedFile = File(image.path);
        bloc.add(SelectImageEvent(selectedFile));
        messenger.showSnackBar(
          SnackBar(content: Text("image selected: ${image.name}")),
        );
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text("Error getting image:$e")));
    }
  }

  void _uploadImage(File imageFile) {
    if (currentEmail != null) {
      final description = _descriptionController.text.trim();
      context.read<ImageBloc>().add(
        UploadImageEvent(
          imageFile,
          currentEmail!,
          description: description.isNotEmpty ? description : null,
        ),
      );
    }
  }

  void _saveDescription() {
    if (currentEmail != null && _descriptionController.text.trim().isNotEmpty) {
      context.read<ImageBloc>().add(
        SaveDescriptionEvent(_descriptionController.text.trim(), currentEmail!),
      );
    }
  }

  ImageProvider<Object>? _buildProfileImage(ImageState state) {
    if (state is ImageSelected) {
      return FileImage(state.selectedFile);
    }
    if (state is ImageUploading) {
      return FileImage(state.selectedFile);
    }
    if (state is ImageUploaded) {
      return NetworkImage(state.imageUrl);
    }
    if (state is ImageLoaded) {
      return NetworkImage(state.imageUrl);
    }
    if (state is ImageUploadFailed && state.selectedFile != null) {
      return FileImage(state.selectedFile!);
    }
    return null;
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
