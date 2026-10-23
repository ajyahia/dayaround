import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimy/features/week/domain/models/week_start_day.dart';
import 'package:jimy/features/week/presentation/controllers/week_settings_controller.dart';

class WeekStartSettingsScreen extends ConsumerWidget {
  const WeekStartSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDay = ref.watch(weekStartDayProvider);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        previousPageTitle: 'الإعدادات',
        middle: Text('بداية الأسبوع'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('اليوم الذي يبدأ به الأسبوع في التخطيط'),
              footer: const Text(
                'السبت هو اليوم الافتراضي المعتمد في معظم الدول العربية، ويمكنك تغييره إلى الأحد أو الإثنين.',
              ),
              children: WeekStartDay.values.map((day) {
                final isSelected = day == currentDay;

                return CupertinoListTile(
                  title: Text(day.labelArabic),
                  trailing: isSelected
                      ? const Icon(
                          CupertinoIcons.checkmark,
                          color: CupertinoColors.systemBlue,
                        )
                      : null,
                  onTap: () {
                    ref.read(weekStartDayProvider.notifier).update(day);
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
