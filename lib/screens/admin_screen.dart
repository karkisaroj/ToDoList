import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ToDoList/bloc/auth/auth_bloc.dart';
import 'package:ToDoList/bloc/auth/auth_event.dart';
import 'package:ToDoList/bloc/auth/auth_state.dart';
import 'package:ToDoList/bloc/task/task_bloc.dart';
import 'package:ToDoList/bloc/task/task_event.dart';
import 'package:ToDoList/bloc/task/task_state.dart';
import 'package:ToDoList/screens/register.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasksEvent());
  }

  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Register()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text("Admin Screen"), centerTitle: true),
        bottomNavigationBar: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return CircularProgressIndicator();
            }
            return ElevatedButton(
              onPressed: () async {
                context.read<AuthBloc>().add(LogoutRequested());
              },
              child: Text(
                "Sign Out",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            );
          },
        ),
        body: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return Center(child: CircularProgressIndicator());
            }
            if (state is TaskError) {
              return Center(child: Text("Error : ${state.message}"));
            }
            if (state is TaskLoaded) {
              if (state.tasks.isEmpty) {
                return Center(child: Text("No tasks found"));
              }

              return ListView.builder(
                itemCount: state.tasks.length,
                itemBuilder: (context, index) {
                  final task = state.tasks[index];
                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
                              context.read<TaskBloc>().add(
                                DeleteTaskEvent(
                                  taskID: task.taskId,
                                  userEmail: "",
                                ),
                              );
                            },
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return Center(child: Text("No tasks"));
          },
        ),
      ),
    );
  }
}
