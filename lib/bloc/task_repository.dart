import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_management/model/task_model.dart';

class TaskRepository {
  final FirebaseFirestore _firestore;

  TaskRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Task> _tasksRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .withConverter<Task>(
          fromFirestore:
              (snapshot, _) => Task.fromJson(snapshot.data()!, snapshot.id),
          toFirestore: (task, _) => task.toJson(),
        );
  }

  Stream<List<Task>> getTasks(String userId) {
    return _tasksRef(userId)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addTask(String userId, Task task) async {
    await _tasksRef(userId).add(task);
  }

  Future<void> updateTask(String userId, Task task) async {
    if (task.id == null) {
      throw Exception("Task ID is missing");
    }
    await _tasksRef(userId).doc(task.id).update(task.toJson());
  }

  Future<void> deleteTask(String userId, String taskId) async {
    await _tasksRef(userId).doc(taskId).delete();
  }
}
