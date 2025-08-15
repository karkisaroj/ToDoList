import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intern01/bloc/auth/auth_bloc.dart';
import 'package:intern01/bloc/auth/auth_state.dart';
import 'package:intern01/bloc/image/image_bloc.dart';
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
      currentUserEmail = authState.email;
      context.read<ImageBloc>().add(LoadUserImageEvent(authState.email));
    }
  }

  Future<void> _pickImage() async {
    final bloc = context.read<ImageBloc>();
    final messenger = ScaffoldMessenger.of(context);
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
        bloc.add(SelectImageEvent(selectedFile));

        messenger.showSnackBar(
          SnackBar(
            content: Text('Image selected: ${image.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: BlocBuilder<ImageBloc, ImageState>(
                        builder: (context, state) {
                          final profileImage = _buildProfileImage(state);
                          return Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            color: colorScheme.surface,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 24,
                              ),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 48,
                                    backgroundColor: colorScheme.onSurface
                                        .withOpacity(0.08),
                                    backgroundImage: profileImage,
                                    child: profileImage == null
                                        ? Icon(
                                            Icons.person,
                                            size: 48,
                                            color: colorScheme.onSurface
                                                .withOpacity(0.5),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    currentUserEmail ?? 'No email',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: _pickImage,
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Edit Profile Picture'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  BlocBuilder<ImageBloc, ImageState>(
                                    builder: (context, state) {
                                      if (state is ImageSelected ||
                                          (state is ImageUploadFailed &&
                                              state.selectedFile != null)) {
                                        final file = state is ImageSelected
                                            ? state.selectedFile
                                            : (state as ImageUploadFailed)
                                                  .selectedFile!;
                                        return Padding(
                                          padding: const EdgeInsets.only(),
                                          child: ElevatedButton.icon(
                                            onPressed: () => _uploadImage(file),
                                            icon: const Icon(Icons.save),
                                            label: const Text(
                                              'Save Profile Picture',
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(50),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Profile Description',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _descriptionController,
                              maxLines: 3,
                              style: TextStyle(color: colorScheme.onSurface),
                              decoration: InputDecoration(
                                hintText: 'Write something about yourself...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),

                                filled: true,
                                fillColor: colorScheme.surfaceContainerHighest,
                                contentPadding: const EdgeInsets.all(40),
                                hintStyle: TextStyle(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _saveDescription,
                                  icon: const Icon(Icons.save, size: 15),
                                  label: const Text('Save'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    BlocBuilder<ImageBloc, ImageState>(
                      builder: (context, state) {
                        if (state is ImageUploading) {
                          return Column(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 8),
                              const Text('Uploading image and description...'),
                            ],
                          );
                        } else if (state is ImageUploaded) {
                          return const Text(
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
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              if (state.selectedFile != null)
                                ElevatedButton(
                                  onPressed: () =>
                                      _uploadImage(state.selectedFile!),
                                  child: const Text("Retry Upload"),
                                ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 24),
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
                            color: colorScheme.secondary.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current Description:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    description,
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          builder: (context) {
                            return Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Settings',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  BlocBuilder<ThemeBloc, ThemeState>(
                                    builder: (context, themeState) {
                                      return ListTile(
                                        leading: Icon(
                                          themeState is DarkTheme
                                              ? Icons.light_mode
                                              : Icons.dark_mode,
                                          color: const Color(0xFF4A4E69),
                                        ),
                                        title: Text(
                                          themeState is DarkTheme
                                              ? 'Switch to Light Mode'
                                              : 'Switch to Dark Mode',
                                        ),
                                        onTap: () {
                                          if (themeState is DarkTheme) {
                                            context.read<ThemeBloc>().add(
                                              ToggleLight(),
                                            );
                                          } else {
                                            context.read<ThemeBloc>().add(
                                              ToggleDark(),
                                            );
                                          }
                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.settings),
                      label: const Text("Settings"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF22223B),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(
                          color: Color(0xFF4A4E69),
                          width: 1,
                        ),
                      ),
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
