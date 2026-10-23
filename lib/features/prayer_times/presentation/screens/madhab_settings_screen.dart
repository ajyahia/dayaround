import 'package:adhan/adhan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimy/features/prayer_times/domain/models/prayer_settings.dart';
import 'package:jimy/features/prayer_times/presentation/controllers/prayer_times_providers.dart';

class MadhabSettingsScreen extends ConsumerWidget {
  const MadhabSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(prayerSettingsProvider);
    final currentMadhab = settings.madhab;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        previousPageTitle: 'الإعدادات',
        middle: Text('مذهب صلاة العصر'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('المذهب الفقهي المعتمد لصلاة العصر'),
              footer: const Text(
                'مذهب الجمهور: يدخل وقت العصر عندما يصبح ظل الشيء مثله. مذهب الحنفي: عندما يصبح ظل الشيء مثليه.',
              ),
              children: Madhab.values.map((madhab) {
                final isSelected = madhab == currentMadhab;
                final name = PrayerSettings.getMadhabArabicName(madhab);

                return CupertinoListTile(
                  title: Text(name),
                  trailing: isSelected
                      ? const Icon(
                          CupertinoIcons.checkmark,
                          color: CupertinoColors.systemBlue,
                        )
                      : null,
                  onTap: () {
                    ref
                        .read(prayerSettingsProvider.notifier)
                        .updateMadhab(madhab);
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
