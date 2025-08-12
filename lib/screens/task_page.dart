import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intern01/screens/post_screen.dart';
import 'package:intern01/screens/profile_page.dart';
import 'package:intern01/screens/register.dart';
import 'package:intern01/bloc/auth/auth_bloc.dart';
import 'package:intern01/bloc/auth/auth_event.dart';
import 'package:intern01/bloc/auth/auth_state.dart';
import 'package:intern01/bloc/task/task_bloc.dart';
import 'package:intern01/bloc/task/task_event.dart';
import 'package:intern01/bloc/task/task_state.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  String? currentUserEmail;
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadUserTasks();
  }

  void _loadUserTasks() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      currentUserEmail = authState.email;
      context.read<TaskBloc>().add(
        LoadUserTaskEvent(userEmail: authState.email),
      );
    }
  }

  void _showAddTaskDialog() {
    String taskTitle = '';
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Add New Task"),
          content: TextField(
            onChanged: (value) => taskTitle = value,
            decoration: InputDecoration(labelText: "Task title"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (taskTitle.isNotEmpty && currentUserEmail != null) {
                  context.read<TaskBloc>().add(
                    AddTaskEvent(
                      title: taskTitle,
                      userEmail: currentUserEmail!,
                      task: taskTitle,
                    ),
                  );
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

  Widget _buildTaskList() {
    return BlocBuilder<TaskBloc, TaskState>(
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
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  leading: IconButton(
                    icon: Icon(
                      task.isCompleted
                          ? Icons.check_circle
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
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
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
                  ),
                ),
              );
            },
          );
        }
        return Center(child: Text("Welcome to Tasks"));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Register()),
            (route) => false,
          );
        } else if (state is AuthSuccess) {
          currentUserEmail = state.email;
          if (_currentIndex == 0) {
            context.read<TaskBloc>().add(
              LoadUserTaskEvent(userEmail: state.email),
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(['Tasks', 'Profile', 'Settings'][_currentIndex]),
          actions: [
            if (_currentIndex == 0)
              IconButton(icon: Icon(Icons.add), onPressed: _showAddTaskDialog),
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(LogoutRequested());
              },
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
            if (index == 0) _loadUserTasks();
          },
          children: [_buildTaskList(), ProfilePage(), PostScreen()],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
