import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jimy/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App shell renders with 3 tabs and navigates to appearance sub-page', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JimyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial tab (Today / اليوم) is visible with smart cards and sample sections
    expect(find.text('اليوم'), findsWidgets);
    expect(find.text('الأسبوع'), findsOneWidget);
    expect(find.text('الإعدادات'), findsOneWidget);
    expect(find.text('الصلاة القادمة'), findsOneWidget);
    expect(find.text('مهام اليوم'), findsOneWidget);

    // Tap on Settings tab
    await tester.tap(find.text('الإعدادات'));
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
  });
}
