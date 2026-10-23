import 'package:adhan/adhan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimy/features/prayer_times/domain/models/prayer_settings.dart';
import 'package:jimy/features/prayer_times/presentation/controllers/prayer_times_providers.dart';

class CalculationSettingsScreen extends ConsumerWidget {
  const CalculationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(prayerSettingsProvider);
    final currentMethod = settings.method;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        previousPageTitle: 'الإعدادات',
        middle: Text('طريقة الحساب'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('طرق حساب مواقيت الصلاة المدعومة'),
              footer: const Text(
                'تحدد طريقة الحساب زوايا الفجر والعشاء المعتمدة في كل دولة.',
              ),
              children: CalculationMethod.values.map((method) {
                final isSelected = method == currentMethod;
                final name = PrayerSettings.getMethodArabicName(method);

                return CupertinoListTile(
                  title: Text(name),
                  subtitle: Text(method.name),
                  trailing: isSelected
                      ? const Icon(
                          CupertinoIcons.checkmark,
                          color: CupertinoColors.systemBlue,
                        )
                      : null,
                  onTap: () {
                    ref
                        .read(prayerSettingsProvider.notifier)
                        .updateMethod(method);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
