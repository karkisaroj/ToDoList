import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intern01/auth/auth_call.dart';
import 'package:intern01/models/list_model.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool isChecked = false;
  Future<void> deleteTask(String taskId) async {
    await FirebaseFirestore.instance.collection("tasks").doc(taskId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Screen"), centerTitle: true),
      bottomNavigationBar: ElevatedButton(
        onPressed: () async {
          AuthCall auth = AuthCall();
          auth.signOut();
        },
        child: Text(
          "Sign Out",
          style: TextStyle(
            fontSize: 10.h,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('tasks').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error : ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No tasks found"));
          }
          final tasks = snapshot.data!.docs
              .map((doc) => ListModel.fromDocument(doc))
              .toList();
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(horizontal: 10.h, vertical: 12.w),
                child: ListTile(
                  tileColor: Colors.white10,
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(value: task.isCompleted, onChanged: null),
                      IconButton(
                        onPressed: () {
                          deleteTask(task.taskId);
                          setState(() {});
                        },
                        icon: Icon(Icons.delete),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
