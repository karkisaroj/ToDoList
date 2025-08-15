import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      currentUserEmail = authState.email;
    }
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
        content: Column(
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
    return Scaffold(
      body: BlocListener<ImageBloc, ImageState>(
        listener: (context, state) async {
          if (state is ImageUploaded) {
            await FirebaseFirestore.instance.collection('posts').add({
              'imageUrl': state.imageUrl,
              'description': state.description ?? '',
              'email': currentUserEmail,
              'timestamp': FieldValue.serverTimestamp(),
            });
          }
        },
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
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
                final imageUrl = data['imageUrl'] ?? '';
                final description = data['description'] ?? '';
                return Container(
                  padding: EdgeInsets.all(18),
                  child: Card(
                    margin: EdgeInsets.all(12),
                    child: Column(
                      children: [
                        if (imageUrl.isNotEmpty)
                          Image.network(
                            imageUrl,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        SizedBox(height: 25),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Center(child: Text(description)),
                            SizedBox(height: 16),
                            FloatingActionButton(
                              mini: true,
                              backgroundColor: Colors.white,
                              splashColor: Colors.red,
                              onPressed: () {
                                context.read<ImageBloc>().add(
                                  DeleteImageEvent(docId),
                                );
                              },
                              child: Icon(Icons.delete),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostDialog,
        splashColor: Colors.red,
        child: Icon(Icons.add),
      ),
    );
  }
}
