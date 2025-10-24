import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_management/bloc/tasks_bloc.dart';
import 'package:task_management/bloc/tasks_event.dart';
import 'package:task_management/model/task_model.dart';
import 'package:task_management/model/add_task_modal.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final tasksBlocContext = context;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        tasksBlocContext.read<TasksBloc>().add(TaskDeleted(task.id!));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (bottomSheetContext) {
                return BlocProvider.value(
                  value: context.read<TasksBloc>(),
                  child: AddTaskModal(task: task),
                );
              },
            );
          },
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (val) {
              tasksBlocContext.read<TasksBloc>().add(
                TaskUpdated(task.copyWith(isCompleted: val ?? false)),
              );
            },
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration:
                  task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
              color: task.isCompleted ? Colors.grey : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            task.dueDate != null
                ? DateFormat('d MMM, h:mm a').format(task.dueDate!)
                : 'No due date',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: _PriorityChip(priority: task.priority),
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final TaskPriority priority;
  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    Color textColor;
    String label;
    switch (priority) {
      case TaskPriority.high:
        chipColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        label = 'High';
        break;
      case TaskPriority.medium:
        chipColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        label = 'Medium';
        break;
      case TaskPriority.low:
      default:
        chipColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        label = 'Low';
    }
    return Chip(
      label: Text(label),
      backgroundColor: chipColor,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
