abstract class TaskEvent {}

class LoadTasksEvent extends TaskEvent {}

class DeleteTaskEvent extends TaskEvent {
  final String taskID;
  final String userEmail;
  DeleteTaskEvent({required this.taskID, required this.userEmail});
}

class AddTaskEvent extends TaskEvent {
  final String title;
  final String userEmail;
  AddTaskEvent({
    required this.title,
    required this.userEmail,
    required String task,
  });
}

class ToogleTaskEvent extends TaskEvent {
  final String taskId;
  final bool isCompleted;
  final String userEmail;
  ToogleTaskEvent({
    required this.isCompleted,
    required this.taskId,
    required this.userEmail,
  });
}

class LoadUserTaskEvent extends TaskEvent {
  final String userEmail;
  LoadUserTaskEvent({required this.userEmail});
}
