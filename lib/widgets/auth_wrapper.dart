import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/bloc/auth_bloc.dart';
import 'package:task_management/bloc/auth_state.dart';
import 'package:task_management/bloc/tasks_bloc.dart';
import 'package:task_management/bloc/tasks_event.dart';
import 'package:task_management/bloc/task_repository.dart';
import 'package:task_management/widgets/login_screen.dart';
import 'package:task_management/widgets/tasks_home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is Authenticated) {
          return BlocProvider(
            create:
                (context) => TasksBloc(
                  taskRepository: context.read<TaskRepository>(),
                  userId: state.user.uid,
                )..add(TasksLoadRequested()),
            child: const TasksHomeScreen(),
          );
        }
        if (state is Unauthenticated || state is AuthError) {
          return const LoginScreen();
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
