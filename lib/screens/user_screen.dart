import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intern01/screens/register.dart';
import 'package:intern01/bloc/auth/auth_bloc.dart';
import 'package:intern01/bloc/auth/auth_event.dart';
import 'package:intern01/bloc/auth/auth_state.dart';
import 'package:intern01/bloc/task/task_bloc.dart';
import 'package:intern01/bloc/task/task_event.dart';
import 'package:intern01/bloc/task/task_state.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      if (authState.email.isNotEmpty) {
        currentUserEmail = authState.email;
        context.read<TaskBloc>().add(
          LoadUserTaskEvent(userEmail: authState.email),
        );
      } else {
        context.read<AuthBloc>().add(CheckAuthStatusEvent());
      }
    } else {
      context.read<AuthBloc>().add(CheckAuthStatusEvent());
    }
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
                if (taskTitle.isNotEmpty &&
                    currentUserEmail != null &&
                    currentUserEmail!.isNotEmpty) {
                  context.read<TaskBloc>().add(
                    AddTaskEvent(
                      title: taskTitle,
                      userEmail: currentUserEmail!,
                    ),
                  );

                  if (!mounted) return;
                  Navigator.of(ctx).pop();
                } else {
                  final authUser = FirebaseAuth.instance.currentUser;
                  if (authUser != null &&
                      authUser.email != null &&
                      authUser.email!.isNotEmpty) {
                    context.read<TaskBloc>().add(
                      AddTaskEvent(
                        title: taskTitle,
                        userEmail: authUser.email!,
                      ),
                    );
                    if (!mounted) return;
                    Navigator.of(ctx).pop();
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error: User email not available. Please try logging out and back in.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthSuccess && currentUserEmail != authState.email) {
          currentUserEmail = authState.email;
        }

        return MultiBlocListener(
          listeners: [
            BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthInitial) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => Register()),
                    (route) => false,
                  );
                } else if (state is AuthSuccess) {
                  if (state.email.isNotEmpty) {
                    if (currentUserEmail == null ||
                        currentUserEmail != state.email) {
                      currentUserEmail = state.email;
                      context.read<TaskBloc>().add(
                        LoadUserTaskEvent(userEmail: state.email),
                      );
                    }
                  }
                }
              },
            ),
          ],
          child: Scaffold(
            bottomNavigationBar: ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(LogoutRequested());
              },
              child: const Text('Logout'),
            ),

            body: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return Center(child: CircularProgressIndicator());
                }
                if (state is TaskError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                if (state is TaskLoaded) {
                  if (state.tasks.isEmpty) {
                    return Center(child: Text('No tasks found.'));
                  }

                  return ListView.builder(
                    itemCount: state.tasks.length,
                    itemBuilder: (context, index) {
                      final task = state.tasks[index];
                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(
                          horizontal: 10.h,
                          vertical: 15.w,
                        ),

                        child: Padding(
                          padding: EdgeInsets.all(8.0),
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
                                if (currentUserEmail != null) {
                                  context.read<TaskBloc>().add(
                                    DeleteTaskEvent(
                                      taskID: task.taskId,
                                      userEmail: currentUserEmail!,
                                    ),
                                  );
                                }
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
                                if (currentUserEmail != null) {
                                  context.read<TaskBloc>().add(
                                    ToogleTaskEvent(
                                      taskId: task.taskId,
                                      isCompleted: !task.isCompleted,
                                      userEmail: currentUserEmail!,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return Center(child: Text("No task found"));
              },
            ),

            floatingActionButton: FloatingActionButton(
              onPressed: () => _startAddNewItem(context),
              tooltip: "Add new task",
              child: Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }
}
