import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:task_management/bloc/tasks_event.dart';
import 'package:task_management/bloc/tasks_state.dart';
import 'package:task_management/bloc/task_repository.dart'; // Corrected path

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TaskRepository _taskRepository;
  final String _userId;
  StreamSubscription? _tasksSubscription;

  TasksBloc({required TaskRepository taskRepository, required String userId})
    : _taskRepository = taskRepository,
      _userId = userId,
      super(const TasksState()) {
    on<TasksLoadRequested>(_onTasksLoadRequested);
    on<TasksUpdated>(_onTasksUpdated);
    on<TasksFilterChanged>(_onTasksFilterChanged);
    on<TaskAdded>(_onTaskAdded);
    on<TaskUpdated>(_onTaskUpdated);
    on<TaskDeleted>(_onTaskDeleted);
  }

  void _onTasksLoadRequested(
    TasksLoadRequested event,
    Emitter<TasksState> emit,
  ) {
    emit(state.copyWith(status: TasksStatus.loading));
    _tasksSubscription?.cancel();
    _tasksSubscription = _taskRepository
        .getTasks(_userId)
        .listen(
          (tasks) => add(TasksUpdated(tasks)),
          onError: (error) => emit(state.copyWith(status: TasksStatus.failure)),
        );
  }

  void _onTasksUpdated(TasksUpdated event, Emitter<TasksState> emit) {
    emit(state.copyWith(status: TasksStatus.success, allTasks: event.tasks));
  }

  void _onTasksFilterChanged(
    TasksFilterChanged event,
    Emitter<TasksState> emit,
  ) {
    emit(
      state.copyWith(
        statusFilter: event.statusFilter ?? state.statusFilter,
        priorityFilter: event.priorityFilter ?? state.priorityFilter,
      ),
    );
  }

  void _onTaskAdded(TaskAdded event, Emitter<TasksState> emit) async {
    try {
      await _taskRepository.addTask(_userId, event.task);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void _onTaskUpdated(TaskUpdated event, Emitter<TasksState> emit) async {
    try {
      await _taskRepository.updateTask(_userId, event.task);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void _onTaskDeleted(TaskDeleted event, Emitter<TasksState> emit) async {
    try {
      await _taskRepository.deleteTask(_userId, event.taskId);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
