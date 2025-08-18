import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ToDoList/bloc/auth/auth_bloc.dart';
import 'package:ToDoList/bloc/auth/auth_state.dart';
import 'package:ToDoList/bloc/image_upload/image_bloc.dart';
import 'package:ToDoList/bloc/theme/theme_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();
  String? currentUserEmail;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _loadUserData();
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
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
    if (currentUserEmail == null) {
      _showSnackBar('Please login first', Colors.red.shade600);
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final selectedFile = File(image.path);
        bloc.add(SelectImageEvent(selectedFile));
        _showSnackBar('Image selected successfully', Colors.green.shade600);
      }
    } catch (e) {
      _showSnackBar('Error selecting image: $e', Colors.red.shade600);
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

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              backgroundColor == Colors.green.shade600
                  ? Icons.check_circle
                  : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
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

  Widget _buildProfileSection(ThemeData theme, ImageState state) {
    final profileImage = _buildProfileImage(state);

    final isLight = theme.brightness == Brightness.light;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: isLight
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF8FAFF), Color(0xFFE9F0FB)],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.secondary.withValues(alpha: 0.05),
                ],
              ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isLight
                          ? Colors.blue.withAlpha(30)
                          : theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 64,
                  backgroundColor: isLight
                      ? Colors.white
                      : theme.colorScheme.surface,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: isLight
                        ? const Color(0xFFE9F0FB)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                    backgroundImage: profileImage,
                    child: profileImage == null
                        ? Icon(
                            Icons.person_outline,
                            size: 64,
                            color: isLight
                                ? Colors.blueGrey.withAlpha(120)
                                : theme.colorScheme.primary.withValues(
                                    alpha: 0.6,
                                  ),
                          )
                        : null,
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isLight ? Colors.blue : theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(30),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            currentUserEmail?.split('@')[0].toUpperCase() ?? 'USER',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isLight
                  ? Colors.blueGrey[900]
                  : theme.colorScheme.onSurface,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isLight
                  ? Colors.white
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isLight
                  ? [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              currentUserEmail ?? 'No email',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isLight
                    ? Colors.blueGrey[700]
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(ImageState state, ThemeData theme) {
    if (state is ImageSelected ||
        (state is ImageUploadFailed && state.selectedFile != null)) {
      final file = state is ImageSelected
          ? state.selectedFile
          : (state as ImageUploadFailed).selectedFile!;

      return Container(
        width: double.infinity,
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: ElevatedButton.icon(
          onPressed: () => _uploadImage(file),
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save Profile Picture'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildDescriptionCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.edit_note,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'About Me',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: 4,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Tell us about yourself...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _saveDescription,
                icon: const Icon(Icons.save_outlined, size: 20),
                label: const Text('Save Description'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(ImageState state, ThemeData theme) {
    if (state is ImageUploading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Uploading...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else if (state is ImageUploaded) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
            const SizedBox(width: 12),
            Text(
              'Profile updated successfully!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else if (state is ImageUploadFailed) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error, color: Colors.red.shade600, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Upload failed: ${state.error}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
            if (state.selectedFile != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _uploadImage(state.selectedFile!),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry Upload'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSettingsButton(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton.icon(
          onPressed: () {
            FocusScope.of(context).unfocus();
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(Icons.settings, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          'Settings',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<ThemeBloc, ThemeState>(
                      builder: (context, themeState) {
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              themeState is DarkTheme
                                  ? Icons.light_mode
                                  : Icons.dark_mode,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            themeState is DarkTheme
                                ? 'Switch to Light Mode'
                                : 'Switch to Dark Mode',
                            style: theme.textTheme.bodyLarge,
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: theme.colorScheme.outline,
                          ),
                          onTap: () {
                            if (themeState is DarkTheme) {
                              context.read<ThemeBloc>().add(ToggleLight());
                            } else {
                              context.read<ThemeBloc>().add(ToggleDark());
                            }
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
          icon: const Icon(Icons.settings_outlined),
          label: const Text('Settings'),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            side: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              _showSnackBar(
                'Description saved successfully!',
                Colors.green.shade600,
              );
            }
          },
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      BlocBuilder<ImageBloc, ImageState>(
                        builder: (context, state) =>
                            _buildProfileSection(theme, state),
                      ),
                      const SizedBox(height: 24),
                      BlocBuilder<ImageBloc, ImageState>(
                        builder: (context, state) =>
                            _buildActionButton(state, theme),
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<ImageBloc, ImageState>(
                        builder: (context, state) =>
                            _buildStatusIndicator(state, theme),
                      ),
                      const SizedBox(height: 24),
                      _buildDescriptionCard(theme),
                      _buildSettingsButton(theme),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
