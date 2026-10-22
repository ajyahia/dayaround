import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jimy/core/theme/app_theme.dart';
import 'package:jimy/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App shell renders with 3 tabs and switches to settings', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JimyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial tab (Today / اليوم) is visible
    expect(find.text('اليوم'), findsWidgets);
    expect(find.text('الأسبوع'), findsOneWidget);
    expect(find.text('الإعدادات'), findsOneWidget);

    // Tap on Settings tab
    await tester.tap(find.text('الإعدادات'));
    await tester.pumpAndSettle();

    // Verify settings content
    expect(find.text('المظهر'), findsOneWidget);
    expect(find.text('تلقائي'), findsOneWidget);
    expect(find.text('فاتح'), findsOneWidget);
    expect(find.text('داكن'), findsOneWidget);

    // Tap on dark mode segment
    await tester.tap(find.text('داكن'));
    await tester.pumpAndSettle();

    final segmentedControl = tester.widget<CupertinoSlidingSegmentedControl<AppThemeMode>>(
      find.byType(CupertinoSlidingSegmentedControl<AppThemeMode>),
    );
    expect(segmentedControl.groupValue, AppThemeMode.dark);
  });
}
