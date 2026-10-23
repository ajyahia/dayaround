import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:jimy/features/prayer_times/presentation/controllers/prayer_times_providers.dart';
import 'package:jimy/features/settings/presentation/settings_screen.dart';
import 'package:jimy/features/tasks/domain/models/task_model.dart';
import 'package:jimy/features/week/presentation/screens/week_start_settings_screen.dart';
import 'package:jimy/features/week/presentation/week_screen.dart';
import 'package:jimy/features/week/presentation/widgets/week_day_card.dart';
import 'package:jimy/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('week_test_hive_');
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

  Widget buildTestApp(Widget child) {
    return ProviderScope(
      overrides: [
        currentTimeProvider.overrideWith((ref) => Stream.value(DateTime.now())),
      ],
      child: CupertinoApp(
        locale: const Locale('ar', 'EG'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: child,
      ),
    );
  }

  testWidgets('WeekScreen renders nav bar, 7 day cards, and handles week navigation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestApp(const WeekScreen()));
    await tester.pumpAndSettle();

    // Verify Week Title is visible (e.g. "الأسبوع 43")
    expect(find.textContaining('الأسبوع'), findsOneWidget);

    // Verify Carry Over button is present
    expect(find.byKey(const Key('carry_over_button')), findsOneWidget);

    // Verify 7 day cards are rendered
    expect(find.byType(WeekDayCard), findsNWidgets(7));

    // Tap next week button
    await tester.tap(find.byKey(const Key('next_week_button')));
    await tester.pumpAndSettle();

    // "هذا الأسبوع" icon button appears when offset != 0
    expect(find.byKey(const Key('current_week_button')), findsOneWidget);

    // Tap "هذا الأسبوع" button to return
    await tester.tap(find.byKey(const Key('current_week_button')));
    await tester.pumpAndSettle();

    // "هذا الأسبوع" button disappears when back on current week
    expect(find.byKey(const Key('current_week_button')), findsNothing);

    // Tap carry over button to open CupertinoActionSheet
    await tester.tap(find.byKey(const Key('carry_over_button')));
    await tester.pumpAndSettle();

    expect(find.text('ترحيل المهام غير المنجزة'), findsOneWidget);
    expect(find.text('إلغاء'), findsOneWidget);

    // Cancel action sheet
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();
  });

  testWidgets('Settings screen contains Week Start setting and allows selection', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(const SettingsScreen()));
    await tester.pumpAndSettle();

    // Verify Week Start row exists
    expect(find.text('بداية الأسبوع'), findsOneWidget);
    expect(find.text('السبت'), findsOneWidget);

    // Tap on Week Start row
    await tester.tap(find.text('بداية الأسبوع'));
    await tester.pumpAndSettle();

    // In WeekStartSettingsScreen
    expect(find.byType(WeekStartSettingsScreen), findsOneWidget);
    expect(find.text('الأحد'), findsOneWidget);
    expect(find.text('الإثنين'), findsOneWidget);

    // Select Sunday
    await tester.tap(find.text('الأحد'));
    await tester.pumpAndSettle();

    // Go back to Settings
    final backBtn = find.byType(CupertinoButton);
    if (backBtn.evaluate().isNotEmpty) {
      await tester.tap(backBtn.first);
      await tester.pumpAndSettle();
    }
  });
}
