import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:jimy/features/prayer_times/presentation/controllers/prayer_times_providers.dart';
import 'package:jimy/features/tasks/domain/models/task_model.dart';
import 'package:jimy/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('widget_test_hive_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isBoxOpen('tasks_box')) {
      await Hive.openBox<Task>('tasks_box');
    }
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App renders Week screen cleanly and navigates to appearance settings', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentTimeProvider.overrideWith((ref) => Stream.value(DateTime.now())),
        ],
        child: const JimyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Week board is visible with week title and action buttons
    expect(find.textContaining('الأسبوع'), findsWidgets);
    expect(find.byKey(const Key('settings_button')), findsOneWidget);

    // Tap on Settings button in the top navigation bar
    await tester.tap(find.byKey(const Key('settings_button')));
    await tester.pumpAndSettle();

    // Verify settings rows
    expect(find.text('المظهر'), findsOneWidget);
    expect(find.text('الموقع'), findsOneWidget);
    expect(find.text('طريقة الحساب'), findsOneWidget);

    // Tap on Appearance row to navigate to sub-page
    await tester.tap(find.text('المظهر'));
    await tester.pumpAndSettle();

    // In Appearance sub-page
    expect(find.text('تلقائي'), findsOneWidget);
    expect(find.text('فاتح'), findsOneWidget);
    expect(find.text('داكن'), findsOneWidget);

    // Tap on dark mode
    await tester.tap(find.text('داكن'));
    await tester.pumpAndSettle();

    // Verify checkmark is on dark mode
    expect(find.byIcon(CupertinoIcons.checkmark), findsOneWidget);

    // Clean up
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
