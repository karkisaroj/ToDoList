import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
            .collection("tasks")
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
        add(LoadUserTaskEvent(userEmail: event.userEmail));
      } catch (e) {
        emit(TaskError(message: e.toString()));
      }
    });
    on<AddTaskEvent>((event, emit) async {
      emit(TaskLoading());
      try {
        String userEmail = event.userEmail;
        if (userEmail.isEmpty) {
          userEmail = FirebaseAuth.instance.currentUser?.email ?? "";
        }

        if (userEmail.isEmpty) {
          emit(TaskError(message: "User email not available"));
          return;
        }

        await FirebaseFirestore.instance.collection("tasks").add({
          "title": event.title,
          "created at": Timestamp.now(),
          "userEmail": userEmail,
          "isCompleted": false,
        });
        add(LoadUserTaskEvent(userEmail: userEmail));
      } catch (e) {
        emit(TaskError(message: e.toString()));
      }
    });
    on<ToogleTaskEvent>((event, emit) async {
      emit(TaskLoading());
      try {
        await FirebaseFirestore.instance
            .collection("tasks")
            .doc(event.taskId)
            .update({"isCompleted": event.isCompleted});
        add(LoadUserTaskEvent(userEmail: event.userEmail));
      } catch (e) {
        emit(TaskError(message: e.toString()));
      }
    });
    on<LoadUserTaskEvent>((event, emit) async {
      emit(TaskLoading());
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection("tasks")
            .where('userEmail', isEqualTo: event.userEmail)
            .get();
        final tasks = snapshot.docs
            .map((doc) => ListModel.fromDocument(doc))
            .toList();
        emit(TaskLoaded(tasks: tasks));
      } catch (e) {
        emit(TaskError(message: e.toString()));
      }
    });
  }
}
