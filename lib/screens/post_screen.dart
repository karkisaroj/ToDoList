import 'dart:io';
import 'package:ToDoList/bloc/auth/auth_bloc.dart';
import 'package:ToDoList/bloc/auth/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ToDoList/bloc/image_upload/image_bloc.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final ImagePicker _picker = ImagePicker();
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      currentUserEmail = authState.email;
    }
  }

  void _editPostDialog(
    String postId,
    String currentDescription,
    String currentImageUrl,
  ) async {
    final descriptionController = TextEditingController(
      text: currentDescription,
    );

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BlocListener<ImageBloc, ImageState>(
          listener: (context, state) {
            if (state is ImageUploaded || state is ImageUploadFailed) {
              Navigator.of(context).pop();
            }
          },
          child: BlocBuilder<ImageBloc, ImageState>(
            builder: (context, state) {
              return Dialog(
                insetPadding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 400,
                          maxHeight: MediaQuery.of(context).size.height * 0.8,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: (state is ImageSelected)
                                      ? Image.file(
                                          state.selectedFile,
                                          fit: BoxFit.cover,
                                        )
                                      : (currentImageUrl.isNotEmpty
                                            ? Image.network(
                                                currentImageUrl,
                                                fit: BoxFit.cover,
                                              )
                                            : Center(
                                                child: Icon(
                                                  Icons.image,
                                                  size: 60,
                                                  color: Colors.grey.shade400,
                                                ),
                                              )),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: descriptionController,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  labelText: 'Description',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (state is ImageUploading) ...[
                                const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                const SizedBox(height: 16),
                              ],
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(Icons.add_photo_alternate),
                                    label: const Text("Change Image"),
                                    onPressed: (state is ImageUploading)
                                        ? null
                                        : () async {
                                            final picked = await _picker
                                                .pickImage(
                                                  source: ImageSource.gallery,
                                                );
                                            if (picked != null) {
                                              context.read<ImageBloc>().add(
                                                SelectImageEvent(
                                                  File(picked.path),
                                                ),
                                              );
                                            }
                                          },
                                  ),
                                  FilledButton.icon(
                                    icon: const Icon(Icons.save),
                                    label: const Text("Save Changes"),
                                    onPressed: (state is ImageUploading)
                                        ? null
                                        : () {
                                            context.read<ImageBloc>().add(
                                              EditPostEvent(
                                                postId,
                                                (state is ImageSelected)
                                                    ? state.selectedFile
                                                    : null,
                                                descriptionController.text
                                                    .trim(),
                                              ),
                                            );
                                          },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: (state is ImageUploading)
                                      ? null
                                      : () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showAddPostDialog() async {
    final descriptionController = TextEditingController();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null || currentUserEmail == null) return;
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BlocListener<ImageBloc, ImageState>(
          listener: (context, state) {
            if (state is ImageUploaded || state is ImageUploadFailed) {
              Navigator.of(context).pop();
            }
          },
          child: BlocBuilder<ImageBloc, ImageState>(
            builder: (context, state) {
              if (state is ImageUploading) {
                return const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Uploading post...'),
                    ],
                  ),
                );
              }

              return Dialog(
                insetPadding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(pickedFile.path),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: descriptionController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 10),
                          FilledButton(
                            onPressed: () {
                              context.read<ImageBloc>().add(
                                UploadPostEvent(
                                  descriptionController.text.trim(),
                                  File(pickedFile.path),
                                  currentUserEmail!,
                                ),
                              );
                            },
                            child: const Text('Create Post'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withAlpha((255 * 0.3).toInt()),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No posts yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first post',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }
          final docs = snapshot.data!.docs;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final docId = docs[index].id;
              final data = docs[index].data() as Map<String, dynamic>;
              final imageUrl = data['uploadUrl'] ?? '';
              final description = data['uploadDescription'] ?? '';

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: imageUrl.isNotEmpty
                                ? Image.network(imageUrl, fit: BoxFit.cover)
                                : Container(
                                    color: Colors.grey.shade100,
                                    child: Center(
                                      child: Icon(
                                        Icons.image,
                                        size: 50,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                          ),
                          if (description.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Builder(
                          builder: (context) {
                            final isLight =
                                Theme.of(context).brightness ==
                                Brightness.light;
                            final iconColor = isLight
                                ? Colors.blueGrey[700]
                                : Colors.black87;
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(
                                  (255 * 0.9).toInt(),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: iconColor,
                                    ),
                                    onPressed: () => _editPostDialog(
                                      docId,
                                      description,
                                      imageUrl,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      size: 18,
                                      color: iconColor,
                                    ),
                                    onPressed: () {
                                      context.read<ImageBloc>().add(
                                        DeleteImageEvent(docId),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
