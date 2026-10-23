import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:jimy/core/theme/prayer_block_theme.dart';
import 'package:jimy/features/tasks/data/task_repository.dart';
import 'package:jimy/features/tasks/domain/models/task_model.dart';

/// Box provider, can be overridden in tests
final taskBoxProvider = Provider<Box<Task>>((ref) {
  return Hive.box<Task>('tasks_box');
});

/// Task repository provider
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final box = ref.watch(taskBoxProvider);
  return TaskRepository(box);
});

/// Currently selected date in "yyyy-MM-dd" format
class SelectedDateNotifier extends Notifier<String> {
  @override
  String build() {
    return Task.formatDate(DateTime.now());
  }

  void setDate(DateTime dateTime) {
    state = Task.formatDate(dateTime);
  }

  void setDateString(String dateStr) {
    state = dateStr;
  }
}

final selectedDateProvider =
    NotifierProvider<SelectedDateNotifier, String>(SelectedDateNotifier.new);

/// Stream provider for tasks on a specific date
final tasksForDayProvider =
    StreamProvider.autoDispose.family<List<Task>, String>((ref, date) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchTasksForDay(date);
});

/// Stream provider for tasks within a 7-day week starting at [weekStart]
final tasksForWeekProvider =
    StreamProvider.autoDispose.family<List<Task>, DateTime>((ref, weekStart) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchTasksForWeek(weekStart);
});

/// Tasks for the currently selected date (synchronous list from stream)
final tasksForSelectedDateProvider = Provider.autoDispose<List<Task>>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  final asyncTasks = ref.watch(tasksForDayProvider(selectedDate));
  return asyncTasks.value ?? [];
});

/// Tasks grouped by prayer block for a given date
final tasksByBlockProvider =
    Provider.autoDispose.family<Map<PrayerBlockType, List<Task>>, String>((ref, date) {
  final asyncTasks = ref.watch(tasksForDayProvider(date));
  final tasks = asyncTasks.value ?? [];

  final map = <PrayerBlockType, List<Task>>{
    for (final block in PrayerBlockType.values) block: [],
  };

  for (final task in tasks) {
    map[task.block]?.add(task);
  }

  return map;
});

/// Real-time today's task statistics (total count, done count)
final todayTaskCountsProvider = Provider.autoDispose<(int total, int done)>((ref) {
  final todayStr = Task.formatDate(DateTime.now());
  final asyncTasks = ref.watch(tasksForDayProvider(todayStr));
  final tasks = asyncTasks.value ?? [];
  final total = tasks.length;
  final done = tasks.where((t) => t.isDone).length;
  return (total, done);
});

