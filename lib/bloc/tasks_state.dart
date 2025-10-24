import 'package:equatable/equatable.dart';
import 'package:task_management/model/task_model.dart';

enum StatusFilter { all, incomplete, completed }

enum PriorityFilter { all, low, medium, high }

enum TasksStatus { initial, loading, success, failure }

class TasksState extends Equatable {
  final TasksStatus status;
  final List<Task> allTasks;
  final StatusFilter statusFilter;
  final PriorityFilter priorityFilter;
  final String? errorMessage;

  const TasksState({
    this.status = TasksStatus.initial,
    this.allTasks = const [],
    this.statusFilter = StatusFilter.all,
    this.priorityFilter = PriorityFilter.all,
    this.errorMessage,
  });

  List<Task> get filteredTasks {
    return allTasks.where((task) {
      final statusMatch = switch (statusFilter) {
        StatusFilter.all => true,
        StatusFilter.completed => task.isCompleted,
        StatusFilter.incomplete => !task.isCompleted,
      };

      final priorityMatch = switch (priorityFilter) {
        PriorityFilter.all => true,
        PriorityFilter.low => task.priority == TaskPriority.low,
        PriorityFilter.medium => task.priority == TaskPriority.medium,
        PriorityFilter.high => task.priority == TaskPriority.high,
      };

      return statusMatch && priorityMatch;
    }).toList();
  }

  TasksState copyWith({
    TasksStatus? status,
    List<Task>? allTasks,
    StatusFilter? statusFilter,
    PriorityFilter? priorityFilter,
    String? errorMessage,
  }) {
    return TasksState(
      status: status ?? this.status,
      allTasks: allTasks ?? this.allTasks,
      statusFilter: statusFilter ?? this.statusFilter,
      priorityFilter: priorityFilter ?? this.priorityFilter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allTasks,
    statusFilter,
    priorityFilter,
    errorMessage,
  ];
}
