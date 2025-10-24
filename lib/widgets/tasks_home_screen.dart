import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_management/bloc/auth_bloc.dart';
import 'package:task_management/bloc/auth_event.dart';
import 'package:task_management/bloc/auth_state.dart';
import 'package:task_management/bloc/tasks_bloc.dart';
import 'package:task_management/bloc/tasks_event.dart';
import 'package:task_management/bloc/tasks_state.dart';
import 'package:task_management/bloc/task_repository.dart';
import 'package:task_management/model/add_task_modal.dart';
import 'package:task_management/widgets/task_tile.dart';

class TasksHomeScreen extends StatelessWidget {
  const TasksHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String userId = '';

    if (authState is Authenticated) {
      userId = authState.user.uid;
    } else {
      return const Center(child: Text("Authentication Error"));
    }

    return BlocProvider(
      create: (context) {
        final taskRepository = context.read<TaskRepository>();
        return TasksBloc(taskRepository: taskRepository, userId: userId)
          ..add(TasksLoadRequested());
      },
      child: const _TasksHomeView(),
    );
  }
}

class _TasksHomeView extends StatelessWidget {
  const _TasksHomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.deepPurpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        title: const Text('Task Manager', style: TextStyle(fontSize: 30)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignOutRequested());
            },
          ),
        ],
      ),
      body: BlocConsumer<TasksBloc, TasksState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.errorMessage}')),
            );
          }
        },
        builder: (context, state) {
          if (state.status == TasksStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == TasksStatus.failure) {
            return const Center(
              child: Text('Failed to load tasks. Check Firebase connection.'),
            );
          }

          if (state.filteredTasks.isEmpty) {
            return const Center(child: Text('No tasks found! Add one below.'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Showing ${state.filteredTasks.length} of ${state.allTasks.length} tasks',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: state.filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = state.filteredTasks[index];
                    return TaskTile(task: task);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (ctx) {
              return BlocProvider.value(
                value: context.read<TasksBloc>(),
                child: const AddTaskModal(),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
