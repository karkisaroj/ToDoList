import 'package:cloud_firestore/cloud_firestore.dart';

class ListModel {
  final String taskId;
  final String title;
  final String description;
  bool isCompleted;
  final String userEmail;

  ListModel({
    required this.taskId,
    required this.title,
    required this.isCompleted,
    required this.description,
    required this.userEmail,
  });

  factory ListModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ListModel(
      taskId: doc.id,
      title: data['title'] ?? "",
      description: data['description'] ?? "",
      userEmail: data['userEmail'] ?? "",
      isCompleted: data['isCompleted'] ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'title': title,
      'description': description,
      'user email': userEmail,
      'isCompleted': isCompleted,
    };
  }
}
