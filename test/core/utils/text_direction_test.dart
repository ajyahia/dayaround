import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jimy/core/utils/text_direction.dart';

void main() {
  group('detectTextDirection', () {
    test('"شراء خبز" -> RTL', () {
      expect(detectTextDirection('شراء خبز'), TextDirection.rtl);
    });

    test('"Buy bread" -> LTR', () {
      expect(detectTextDirection('Buy bread'), TextDirection.ltr);
    });

    test('"Call أحمد" -> LTR', () {
      expect(detectTextDirection('Call أحمد'), TextDirection.ltr);
    });

    test('"اتصل بـ John" -> RTL', () {
      expect(detectTextDirection('اتصل بـ John'), TextDirection.rtl);
    });

    test('"" -> RTL', () {
      expect(detectTextDirection(''), TextDirection.rtl);
    });

    test('whitespace only -> RTL', () {
      expect(detectTextDirection('   '), TextDirection.rtl);
    });

    test('numbers then Arabic -> RTL', () {
      expect(detectTextDirection('123 شراء'), TextDirection.rtl);
    });

    test('numbers then English -> LTR', () {
      expect(detectTextDirection('123 Buy'), TextDirection.ltr);
    });
  });

  group('DirectionalTextField', () {
    testWidgets('starts with RTL when empty and updates dynamically while typing', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: DirectionalTextField(
              controller: controller,
            ),
          ),
        ),
      );

      // Verify initial empty state is RTL
      var textField = tester.widget<CupertinoTextField>(find.byType(CupertinoTextField));
      expect(textField.textDirection, TextDirection.rtl);
      expect(textField.textAlign, TextAlign.right);

      // Type English text
      await tester.enterText(find.byType(CupertinoTextField), 'Call أحمد');
      await tester.pump();

      textField = tester.widget<CupertinoTextField>(find.byType(CupertinoTextField));
      expect(textField.textDirection, TextDirection.ltr);
      expect(textField.textAlign, TextAlign.left);

      // Change to Arabic text
      await tester.enterText(find.byType(CupertinoTextField), 'اتصل بـ John');
      await tester.pump();

      textField = tester.widget<CupertinoTextField>(find.byType(CupertinoTextField));
      expect(textField.textDirection, TextDirection.rtl);
      expect(textField.textAlign, TextAlign.right);
    });
  });
}
