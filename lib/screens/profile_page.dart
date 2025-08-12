import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intern01/bloc/auth/auth_bloc.dart';
import 'package:intern01/bloc/auth/auth_state.dart';
import 'package:intern01/bloc/image_upload/image_bloc.dart';
import 'package:intern01/bloc/theme/theme_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      context.read<ImageBloc>().add(LoadUserImageEvent(authState.email));
    }
  }

  Future<void> _pickImage() async {
    if (currentUserEmail == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please login first')));
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (image != null) {
        final selectedFile = File(image.path);
        context.read<ImageBloc>().add(SelectImageEvent(selectedFile));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image selected: ${image.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _uploadImage(File imageFile) {
    if (currentUserEmail != null) {
      final description = _descriptionController.text.trim();
      context.read<ImageBloc>().add(
        UploadImageEvent(
          imageFile,
          currentUserEmail!,
          description: description.isNotEmpty ? description : null,
        ),
      );
    }
  }

  void _saveDescription() {
    if (currentUserEmail != null &&
        _descriptionController.text.trim().isNotEmpty) {
      context.read<ImageBloc>().add(
        SaveDescriptionEvent(
          _descriptionController.text.trim(),
          currentUserEmail!,
        ),
      );
    }
  }

  ImageProvider<Object>? _buildProfileImage(ImageState state) {
    if (state is ImageSelected) {
      return FileImage(state.selectedFile);
    } else if (state is ImageUploading) {
      return FileImage(state.selectedFile);
    } else if (state is ImageUploaded) {
      return NetworkImage(state.imageUrl);
    } else if (state is ImageLoaded) {
      return NetworkImage(state.imageUrl);
    } else if (state is ImageUploadFailed && state.selectedFile != null) {
      return FileImage(state.selectedFile!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is AuthSuccess && currentUserEmail != authState.email) {
            currentUserEmail = authState.email;
            context.read<ImageBloc>().add(LoadUserImageEvent(authState.email));
          }
        },
        child: BlocListener<ImageBloc, ImageState>(
          listener: (context, imageState) {
            if (imageState is ImageLoaded && imageState.description != null) {
              _descriptionController.text = imageState.description!;
            }
            if (imageState is DescriptionSaved) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Description saved successfully!')),
              );
            }
          },
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    BlocBuilder<ImageBloc, ImageState>(
                      builder: (context, state) {
                        final profileImage = _buildProfileImage(state);

                        return CircleAvatar(
                          backgroundColor: Colors.purple.shade200,
                          backgroundImage: profileImage,
                          child: profileImage == null
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.purple,
                                )
                              : null,
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Profile Page',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (currentUserEmail != null)
                      Text('Welcome, $currentUserEmail')
                    else
                      Text('Your profile information will appear here'),

                    SizedBox(height: 30),

                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile Description',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Write something about yourself...',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(12),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _saveDescription,
                                  icon: Icon(Icons.save),
                                  label: Text('Save Description'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    BlocBuilder<ImageBloc, ImageState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: Icon(Icons.camera_alt),
                              label: Text("Select Profile Picture"),
                            ),
                            if (state is ImageSelected) ...[
                              SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _uploadImage(state.selectedFile),
                                icon: Icon(Icons.cloud_upload),
                                label: Text("Upload with Description"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.read<ImageBloc>().add(
                                    ClearImageEvent(),
                                  );
                                },
                                icon: Icon(Icons.delete),
                                label: Text("Cancel"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),

                    SizedBox(height: 20),

                    BlocBuilder<ImageBloc, ImageState>(
                      builder: (context, state) {
                        if (state is ImageUploading) {
                          return Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 8),
                              Text('Uploading image and description...'),
                            ],
                          );
                        } else if (state is ImageUploaded) {
                          return Text(
                            'Image and description uploaded successfully!',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else if (state is ImageUploadFailed) {
                          return Column(
                            children: [
                              Text(
                                'Upload failed: ${state.error}',
                                style: TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              if (state.selectedFile != null)
                                ElevatedButton(
                                  onPressed: () =>
                                      _uploadImage(state.selectedFile!),
                                  child: Text("Retry Upload"),
                                ),
                            ],
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),

                    SizedBox(height: 20),

                    BlocBuilder<ImageBloc, ImageState>(
                      builder: (context, state) {
                        String? description;
                        if (state is ImageLoaded) {
                          description = state.description;
                        } else if (state is ImageUploaded) {
                          description = state.description;
                        }

                        if (description != null && description.isNotEmpty) {
                          return Card(
                            color: Colors.blue.shade50,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current Description:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(description),
                                ],
                              ),
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Setting"),
                              content: BlocBuilder<ThemeBloc, ThemeState>(
                                builder: (context, themeState) {
                                  return TextButton(
                                    onPressed: () {
                                      if (themeState is DarkTheme) {
                                        context.read<ThemeBloc>().add(
                                          ToggleLight(),
                                        );
                                      } else {
                                        context.read<ThemeBloc>().add(
                                          ToggleDark(),
                                        );
                                      }
                                    },
                                    child: Icon(
                                      themeState is DarkTheme
                                          ? Icons.light_mode
                                          : Icons.dark_mode,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                      child: Text("Go to settings"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
