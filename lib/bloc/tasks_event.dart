import 'package:equatable/equatable.dart';
import 'package:task_management/bloc/tasks_state.dart';
import 'package:task_management/model/task_model.dart';

abstract class TasksEvent extends Equatable {
  const TasksEvent();
  @override
  List<Object?> get props => [];
}

class TasksLoadRequested extends TasksEvent {}

class TasksUpdated extends TasksEvent {
  final List<Task> tasks;
  const TasksUpdated(this.tasks);
  @override
  List<Object> get props => [tasks];
}

class TaskAdded extends TasksEvent {
  final Task task;
  const TaskAdded(this.task);
  @override
  List<Object> get props => [task];
}

class TaskUpdated extends TasksEvent {
  final Task task;
  const TaskUpdated(this.task);
  @override
  List<Object> get props => [task];
}

class TaskDeleted extends TasksEvent {
  final String taskId;
  const TaskDeleted(this.taskId);
  @override
  List<Object> get props => [taskId];
}

class TasksFilterChanged extends TasksEvent {
  final StatusFilter? statusFilter;
  final PriorityFilter? priorityFilter;

  const TasksFilterChanged({this.statusFilter, this.priorityFilter});

  @override
  List<Object?> get props => [statusFilter, priorityFilter];
}
