import 'dart:async';
import 'package:hive_ce/hive.dart';
import 'package:jimy/core/theme/prayer_block_theme.dart';
import 'package:jimy/features/tasks/domain/models/task_model.dart';

class TaskRepository {
  final Box<Task> _box;

  TaskRepository(this._box);

  Box<Task> get box => _box;

  Future<void> addTask(Task task) async {
    await _box.put(task.id, task);
  }

  Future<void> updateTask(Task task) async {
    await _box.put(task.id, task);
  }

  Future<void> deleteTask(String taskId) async {
    await _box.delete(taskId);
  }

  Future<void> toggleDone(String taskId) async {
    final task = _box.get(taskId);
    if (task == null) return;
    final newIsDone = !task.isDone;
    final updated = task.copyWith(
      isDone: newIsDone,
      completedAt: newIsDone ? DateTime.now() : null,
      clearCompletedAt: !newIsDone,
    );
    await _box.put(taskId, updated);
  }

  Future<void> moveTask(
    String taskId, {
    required String newDate,
    required PrayerBlockType newBlock,
  }) async {
    final task = _box.get(taskId);
    if (task == null) return;
    final updated = task.copyWith(
      date: newDate,
      block: newBlock,
    );
    await _box.put(taskId, updated);
  }

  Future<void> reorderWithinBlock({
    required String date,
    required PrayerBlockType block,
    required List<String> taskIdsInOrder,
  }) async {
    for (int i = 0; i < taskIdsInOrder.length; i++) {
      final taskId = taskIdsInOrder[i];
      final task = _box.get(taskId);
      if (task != null && task.date == date && task.block == block) {
        await _box.put(taskId, task.copyWith(sortOrder: i));
      }
    }
  }

  List<Task> getTasksForDay(String date) {
    final tasks = _box.values.where((t) => t.date == date).toList();
    tasks.sort((a, b) {
      final orderCompare = a.sortOrder.compareTo(b.sortOrder);
      if (orderCompare != 0) return orderCompare;
      return a.createdAt.compareTo(b.createdAt);
    });
    return tasks;
  }

  List<Task> getTasksForWeek(DateTime weekStart) {
    final startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final endDate = startDate.add(const Duration(days: 7));

    final tasks = _box.values.where((t) {
      final taskDate = Task.parseDate(t.date);
      return (taskDate.isAfter(startDate) ||
              taskDate.isAtSameMomentAs(startDate)) &&
          taskDate.isBefore(endDate);
    }).toList();

    tasks.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;
      final blockCompare = a.block.index.compareTo(b.block.index);
      if (blockCompare != 0) return blockCompare;
      final orderCompare = a.sortOrder.compareTo(b.sortOrder);
      if (orderCompare != 0) return orderCompare;
      return a.createdAt.compareTo(b.createdAt);
    });

    return tasks;
  }

  Stream<List<Task>> watchTasksForDay(String date) async* {
    yield getTasksForDay(date);
    yield* _box.watch().map((_) => getTasksForDay(date));
  }

  Stream<List<Task>> watchTasksForWeek(DateTime weekStart) async* {
    yield getTasksForWeek(weekStart);
    yield* _box.watch().map((_) => getTasksForWeek(weekStart));
  }
}
