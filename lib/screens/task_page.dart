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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Add New Task",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (value) => taskTitle = value,
                  decoration: InputDecoration(
                    labelText: "Task title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Color(0xFFF6F8FA),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22223B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Add"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskList() {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TaskError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        if (state is TaskLoaded) {
          if (state.tasks.isEmpty) {
            return const Center(child: Text('No tasks found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            itemCount: state.tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final task = state.tasks[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                color: Colors.white,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: IconButton(
                    icon: Icon(
                      task.isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: task.isCompleted ? Colors.green : Colors.grey,
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
                  title: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF22223B),
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
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
        return const Center(child: Text("Welcome to Tasks"));
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
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          title: Text(
            ['Tasks', 'Profile', 'Posts'][_currentIndex],
            style: const TextStyle(
              color: Color(0xFF22223B),
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFF4A4E69)),
              onPressed: () {
                context.read<AuthBloc>().add(LogoutRequested());
              },
              tooltip: 'Logout',
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
            if (index == 0) _loadUserTasks();
          },
          children: [
            Stack(
              children: [
                _buildTaskList(),
                if (_currentIndex == 0)
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: FloatingActionButton(
                      onPressed: _showAddTaskDialog,
                      backgroundColor: const Color(0xFF22223B),
                      foregroundColor: Colors.white,
                      child: const Icon(Icons.add),
                    ),
                  ),
              ],
            ),
            ProfilePage(),
            PostScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _currentIndex,
          selectedItemColor: const Color(0xFF22223B),
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() => _currentIndex = index);
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.post_add), label: 'Posts'),
          ],
        ),
      ),
    );
  }
}
