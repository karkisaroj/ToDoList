import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intern01/repositories/auth_repository.dart';
import 'package:intern01/models/list_model.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final List<ListModel> _tasks = [];

  void _addNewTask(
    String title,
    String description,
    String userEmail,
    String docId,
  ) {
    final newTask = ListModel(
      taskId: docId,
      isCompleted: false,
      title: title,
      description: description,
      userEmail: userEmail,
    );
    setState(() {
      _tasks.add(newTask);
    });
    log("Task added: $title, Total tasks: ${_tasks.length}");
  }

  Future<void> toggleTaskCompletion(String taskId, bool currentState) async {
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
      'isCompleted': !currentState,
    });
  }

  Future<void> deleteTask(String taskId) async {
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
  }

  void _startAddNewItem(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        String taskTitle = '';
        return AlertDialog(
          title: Text("Add new task"),
          content: TextField(
            onChanged: (value) {
              taskTitle = value;
            },
            decoration: InputDecoration(labelText: "Task title"),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (taskTitle.isNotEmpty) {
                  final user = FirebaseAuth.instance.currentUser;
                  final email = user?.email ?? '';

                  final docRef = await FirebaseFirestore.instance
                      .collection('tasks')
                      .add(({
                        'title': taskTitle,
                        'created at': Timestamp.now(),
                        'userEmail': email,
                        'isCompleted': false,
                      }));
                  _addNewTask(taskTitle, '', email, docRef.id);

                  if (!mounted) return;
                  Navigator.of(ctx).pop();
                }
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ElevatedButton(
        onPressed: () {
          AuthCall auth = AuthCall();
          auth.signOut();
        },
        child: const Text('Logout'),
      ),

      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('tasks')
            .where(
              'userEmail',
              isEqualTo: FirebaseAuth.instance.currentUser?.email,
            )
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No tasks found.'));
          }
          final tasks = snapshot.data!.docs
              .map((doc) => ListModel.fromDocument(doc))
              .toList();
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(horizontal: 10.h, vertical: 15.w),

                child: Padding(
                  padding: EdgeInsetsGeometry.all(8.0),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        deleteTask(task.taskId);
                        setState(() {});
                      },
                      icon: Icon(Icons.delete),
                    ),
                    leading: IconButton(
                      icon: Icon(
                        task.isCompleted
                            ? Icons.check
                            : Icons.radio_button_unchecked,
                      ),
                      onPressed: () {
                        toggleTaskCompletion(task.taskId, task.isCompleted);
                        setState(() {});
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _startAddNewItem(context),
        tooltip: "Add new task",
        child: Icon(Icons.add),
      ),
    );
  }
}
