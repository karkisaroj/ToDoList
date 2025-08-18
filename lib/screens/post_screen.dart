import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ToDoList/bloc/auth/auth_bloc.dart';
import 'package:ToDoList/bloc/auth/auth_state.dart';
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
    TextEditingController descriptionController = TextEditingController(
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
              if (state is ImageUploading) {
                return const Center(child: CircularProgressIndicator());
              }
              return AlertDialog(
                title: const Text("Edit Post"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: (state is ImageSelected)
                              ? Image.file(
                                  state.selectedFile,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : (currentImageUrl.isNotEmpty
                                    ? Image.network(
                                        currentImageUrl,
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        height: 180,
                                        width: double.infinity,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image,
                                          size: 80,
                                          color: Colors.grey,
                                        ),
                                      )),
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: descriptionController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.save),
                            label: const Text("Edit Post"),
                            onPressed: () {
                              context.read<ImageBloc>().add(
                                EditPostEvent(
                                  postId,
                                  (state is ImageSelected)
                                      ? state.selectedFile
                                      : null,
                                  descriptionController.text.trim(),
                                ),
                              );
                            },
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.add_photo_alternate),
                            label: const Text("Add New Picture"),
                            onPressed: () async {
                              final picked = await _picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (picked != null) {
                                context.read<ImageBloc>().add(
                                  SelectImageEvent(File(picked.path)),
                                );
                              }
                            },
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

  void _showAddPostDialog() async {
    TextEditingController descriptionController = TextEditingController();
    XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null || currentUserEmail == null) return;

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Post'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(File(pickedFile.path), height: 120),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(hintText: 'Enter description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<ImageBloc>().add(
                UploadPostEvent(
                  descriptionController.text.trim(),
                  File(pickedFile.path),
                  currentUserEmail!,
                ),
              );
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
        ],
      ),
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
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(child: Text('No posts yet. Tap + to add one.'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final docId = docs[index].id;
              final data = docs[index].data() as Map<String, dynamic>;
              final imageUrl = data['uploadUrl'] ?? '';
              final description = data['uploadDescription'] ?? '';
              return Container(
                padding: EdgeInsets.all(18),
                child: Card(
                  margin: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      if (imageUrl.isNotEmpty)
                        Image.network(imageUrl, height: 200, fit: BoxFit.cover),
                      SizedBox(height: 25),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Center(child: Text(description)),
                          SizedBox(height: 16),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          SizedBox(
                            height: 40,
                            width: 100,
                            child: FloatingActionButton(
                              backgroundColor: Colors.white,
                              splashColor: Colors.red,
                              mini: true,
                              onPressed: () {
                                context.read<ImageBloc>().add(
                                  DeleteImageEvent(docId),
                                );
                                Navigator.of(context).pop();
                              },
                              child: (Icon(Icons.delete)),
                            ),
                          ),

                          SizedBox(
                            height: 40,
                            width: 100,
                            child: FloatingActionButton(
                              backgroundColor: Colors.white,
                              onPressed: () =>
                                  _editPostDialog(docId, description, imageUrl),
                              mini: true,
                              child: Icon(Icons.edit),
                            ),
                          ),
                        ],
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
        splashColor: Colors.red,
        child: Icon(Icons.add),
      ),
    );
  }
}
