import 'package:ToDoList/models/list_model.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<ListModel> tasks;
  TaskLoaded({required this.tasks});
}

class TaskError extends TaskState {
  final String message;
  TaskError({required this.message});
}

class EditTask extends TaskState {
  final String description;
  EditTask(this.description);
}
