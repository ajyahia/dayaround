import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:jimy/core/theme/prayer_block_theme.dart';
import 'package:jimy/features/tasks/data/task_repository.dart';
import 'package:jimy/features/tasks/domain/models/task_model.dart';

void main() {
  late Directory tempDir;
  late Box<Task> box;
  late TaskRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_task_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
    final boxName = 'tasks_box_${DateTime.now().microsecondsSinceEpoch}';
    box = await Hive.openBox<Task>(boxName);
    repository = TaskRepository(box);
  });

  tearDown(() async {
    await box.close();
    await tempDir.delete(recursive: true);
  });

  group('TaskRepository CRUD Operations', () {
    test('addTask with durationMinutes', () async {
      final task = Task(
        id: 'task_1',
        title: 'مراجعة التقرير اليومي',
        notes: 'ملاحظة تجريبية',
        date: '2026-10-23',
        block: PrayerBlockType.afterFajr,
        durationMinutes: 45,
        createdAt: DateTime(2026, 10, 23, 5, 30),
      );

      await repository.addTask(task);

      final tasks = repository.getTasksForDay('2026-10-23');
      expect(tasks.length, 1);
      expect(tasks.first.id, 'task_1');
      expect(tasks.first.title, 'مراجعة التقرير اليومي');
      expect(tasks.first.notes, 'ملاحظة تجريبية');
      expect(tasks.first.block, PrayerBlockType.afterFajr);
      expect(tasks.first.durationMinutes, 45);
      expect(tasks.first.isDone, false);
      expect(tasks.first.completedAt, isNull);
    });

    test('addTask without durationMinutes (null)', () async {
      final task = Task(
        id: 'task_2',
        title: 'مهمة بدون مدة محددة',
        date: '2026-10-23',
        block: PrayerBlockType.afterDhuhr,
        durationMinutes: null,
        createdAt: DateTime(2026, 10, 23, 12, 30),
      );

      await repository.addTask(task);

      final tasks = repository.getTasksForDay('2026-10-23');
      expect(tasks.length, 1);
      expect(tasks.first.id, 'task_2');
      expect(tasks.first.durationMinutes, isNull);
      expect(tasks.first.block, PrayerBlockType.afterDhuhr);
    });

    test('updateTask replaces existing task details', () async {
      final task = Task(
        id: 'task_3',
        title: 'العنوان الأصلي',
        date: '2026-10-23',
        block: PrayerBlockType.afterAsr,
        durationMinutes: 30,
        createdAt: DateTime(2026, 10, 23, 15, 0),
      );
      await repository.addTask(task);

      final updatedTask = task.copyWith(
        title: 'العنوان المعدل',
        durationMinutes: 60,
      );
      await repository.updateTask(updatedTask);

      final tasks = repository.getTasksForDay('2026-10-23');
      expect(tasks.first.title, 'العنوان المعدل');
      expect(tasks.first.durationMinutes, 60);
    });

    test('deleteTask removes task from box', () async {
      final task = Task(
        id: 'task_4',
        title: 'مهمة للحذف',
        date: '2026-10-23',
        block: PrayerBlockType.afterMaghrib,
        createdAt: DateTime(2026, 10, 23, 18, 0),
      );
      await repository.addTask(task);
      expect(repository.getTasksForDay('2026-10-23').length, 1);

      await repository.deleteTask('task_4');
      expect(repository.getTasksForDay('2026-10-23').length, 0);
    });

    test('toggleDone switches isDone and manages completedAt timestamp', () async {
      final task = Task(
        id: 'task_5',
        title: 'مهمة تجربة الإنجاز',
        date: '2026-10-23',
        block: PrayerBlockType.afterIsha,
        isDone: false,
        createdAt: DateTime(2026, 10, 23, 20, 0),
      );
      await repository.addTask(task);

      // Toggle to done
      await repository.toggleDone('task_5');
      var retrieved = repository.getTasksForDay('2026-10-23').first;
      expect(retrieved.isDone, true);
      expect(retrieved.completedAt, isNotNull);

      // Toggle back to not done
      await repository.toggleDone('task_5');
      retrieved = repository.getTasksForDay('2026-10-23').first;
      expect(retrieved.isDone, false);
      expect(retrieved.completedAt, isNull);
    });

    test('moveTask moves task to a new date and a new block', () async {
      final task = Task(
        id: 'task_6',
        title: 'مهمة للنقل',
        date: '2026-10-23',
        block: PrayerBlockType.beforeFajr,
        createdAt: DateTime(2026, 10, 23, 4, 0),
      );
      await repository.addTask(task);

      await repository.moveTask(
        'task_6',
        newDate: '2026-10-24',
        newBlock: PrayerBlockType.afterDhuhr,
      );

      expect(repository.getTasksForDay('2026-10-23'), isEmpty);

      final nextDayTasks = repository.getTasksForDay('2026-10-24');
      expect(nextDayTasks.length, 1);
      expect(nextDayTasks.first.id, 'task_6');
      expect(nextDayTasks.first.date, '2026-10-24');
      expect(nextDayTasks.first.block, PrayerBlockType.afterDhuhr);
    });

    test('reorderWithinBlock correctly adjusts sortOrder for ordered taskIds', () async {
      final t1 = Task(
        id: 't1',
        title: 'أولاً',
        date: '2026-10-23',
        block: PrayerBlockType.afterDhuhr,
        sortOrder: 0,
        createdAt: DateTime(2026, 10, 23, 12, 0),
      );
      final t2 = Task(
        id: 't2',
        title: 'ثانياً',
        date: '2026-10-23',
        block: PrayerBlockType.afterDhuhr,
        sortOrder: 1,
        createdAt: DateTime(2026, 10, 23, 12, 1),
      );
      final t3 = Task(
        id: 't3',
        title: 'ثالثاً',
        date: '2026-10-23',
        block: PrayerBlockType.afterDhuhr,
        sortOrder: 2,
        createdAt: DateTime(2026, 10, 23, 12, 2),
      );

      await repository.addTask(t1);
      await repository.addTask(t2);
      await repository.addTask(t3);

      // Reorder to t3, t1, t2
      await repository.reorderWithinBlock(
        date: '2026-10-23',
        block: PrayerBlockType.afterDhuhr,
        taskIdsInOrder: ['t3', 't1', 't2'],
      );

      final ordered = repository.getTasksForDay('2026-10-23');
      expect(ordered.map((t) => t.id).toList(), ['t3', 't1', 't2']);
      expect(ordered[0].sortOrder, 0);
      expect(ordered[1].sortOrder, 1);
      expect(ordered[2].sortOrder, 2);
    });
  });

  group('TaskRepository Queries & Streams', () {
    test('getTasksForWeek retrieves tasks within 7 days', () async {
      final weekStart = DateTime(2026, 10, 18); // Sunday

      // In range: day 0, day 3, day 6
      await repository.addTask(Task(
        id: 'w0',
        title: 'Day 0',
        date: '2026-10-18',
        block: PrayerBlockType.afterFajr,
        createdAt: DateTime(2026, 10, 18),
      ));
      await repository.addTask(Task(
        id: 'w3',
        title: 'Day 3',
        date: '2026-10-21',
        block: PrayerBlockType.afterAsr,
        createdAt: DateTime(2026, 10, 21),
      ));
      await repository.addTask(Task(
        id: 'w6',
        title: 'Day 6',
        date: '2026-10-24',
        block: PrayerBlockType.afterIsha,
        createdAt: DateTime(2026, 10, 24),
      ));

      // Out of range: day 7, day -1
      await repository.addTask(Task(
        id: 'w_before',
        title: 'Before',
        date: '2026-10-17',
        block: PrayerBlockType.afterDhuhr,
        createdAt: DateTime(2026, 10, 17),
      ));
      await repository.addTask(Task(
        id: 'w7',
        title: 'Day 7 (Next week)',
        date: '2026-10-25',
        block: PrayerBlockType.afterDhuhr,
        createdAt: DateTime(2026, 10, 25),
      ));

      final weekTasks = repository.getTasksForWeek(weekStart);
      expect(weekTasks.length, 3);
      expect(weekTasks.map((t) => t.id).toList(), ['w0', 'w3', 'w6']);
    });

    test('watchTasksForDay emits updates on box changes', () async {
      final stream = repository.watchTasksForDay('2026-10-23');

      expectLater(
        stream,
        emitsInOrder([
          isEmpty, // initial emit
          hasLength(1), // after add
          hasLength(0), // after delete
        ]),
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));
      await repository.addTask(Task(
        id: 'stream_1',
        title: 'Stream test task',
        date: '2026-10-23',
        block: PrayerBlockType.afterFajr,
        createdAt: DateTime.now(),
      ));

      await Future<void>.delayed(const Duration(milliseconds: 20));
      await repository.deleteTask('stream_1');
    });
  });

  group('Task HiveAdapter Serialization', () {
    test('Model serialization and deserialization preserves all fields', () {
      final original = Task(
        id: 'adapter_test',
        title: 'اختبار المحول',
        notes: 'ملاحظة طويلة وتفاصيل إضافية',
        date: '2026-10-23',
        block: PrayerBlockType.afterMaghrib,
        durationMinutes: 90,
        isDone: true,
        sortOrder: 4,
        createdAt: DateTime(2026, 10, 23, 10, 30),
        completedAt: DateTime(2026, 10, 23, 11, 45),
        schemaVersion: 1,
      );

      final json = original.toJson();
      final fromJson = Task.fromJson(json);

      expect(fromJson, equals(original));
      expect(fromJson.durationMinutes, 90);
      expect(fromJson.isDone, true);
      expect(fromJson.block, PrayerBlockType.afterMaghrib);
    });
  });
}
