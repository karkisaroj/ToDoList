import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intern01/bloc/auth/auth_bloc.dart';
import 'package:intern01/bloc/auth/auth_event.dart';
import 'package:intern01/bloc/auth/auth_state.dart';
import 'package:intern01/bloc/task/task_bloc.dart';
import 'package:intern01/bloc/task/task_event.dart';
import 'package:intern01/bloc/task/task_state.dart';
import 'package:intern01/screens/register.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: const Text(
            'Admin Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthLoading) {
                return const LinearProgressIndicator();
              }
              return SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    context.read<AuthBloc>().add(LogoutRequested());
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              );
            },
          ),
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

              return ListView.separated(
                itemCount: state.tasks.length,
                separatorBuilder: (context, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final task = state.tasks[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: colorScheme.surface,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: task.isCompleted
                            ? Colors.greenAccent[100]
                            : colorScheme.primary.withValues(alpha: 0.14),
                        child: Icon(
                          task.isCompleted ? Icons.check_circle : Icons.pending,
                          color: task.isCompleted
                              ? Colors.green
                              : colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: colorScheme.onSurface,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: task.isCompleted,
                            onChanged: null,
                            activeColor: colorScheme.primary,
                          ),
                          IconButton(
                            onPressed: () {
                              context.read<TaskBloc>().add(
                                DeleteTaskEvent(
                                  taskID: task.taskId,
                                  userEmail: '',
                                ),
                              );
                            },
                            icon: Icon(Icons.delete, color: colorScheme.error),
                            tooltip: 'Delete Task',
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
