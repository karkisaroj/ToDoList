abstract class TaskEvent {}

class LoadTasksEvent extends TaskEvent {}

class DeleteTaskEvent extends TaskEvent {
  final String taskID;
  DeleteTaskEvent({required this.taskID});
}

class ToogleTaskEvent extends TaskEvent {
  final String taskId;
  final bool isCompleted;
  ToogleTaskEvent({required this.isCompleted, required this.taskId});
}
