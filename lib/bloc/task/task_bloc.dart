import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intern01/bloc/task/task_event.dart';
import 'package:intern01/bloc/task/task_state.dart';
import 'package:intern01/models/list_model.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc() : super(TaskInitial()) {
    on<LoadTasksEvent>((event, emit) async {
      emit(TaskLoading());
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection("takss")
            .get();
        final tasks = snapshot.docs
            .map((doc) => ListModel.fromDocument(doc))
            .toList();
        emit(TaskLoaded(tasks: tasks));
      } catch (e) {
        emit(TaskError(message: e.toString()));
      }
    });
    on<DeleteTaskEvent>((event, emit) async {
      emit(TaskLoading());
      try {
        await FirebaseFirestore.instance
            .collection("tasks")
            .doc(event.taskID)
            .delete();
        add(LoadTasksEvent());
      } catch (e) {
        emit(TaskError(message: e.toString()));
      }
    });
  }
}
