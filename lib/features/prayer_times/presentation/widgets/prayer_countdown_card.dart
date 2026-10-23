import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jimy/core/widgets/summary_card.dart';
import 'package:jimy/features/prayer_times/presentation/controllers/prayer_times_providers.dart';

class PrayerCountdownCard extends ConsumerWidget {
  final VoidCallback? onTap;

  const PrayerCountdownCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextPrayer = ref.watch(nextPrayerProvider);

    if (nextPrayer == null) {
      return SummaryCard(
        title: 'الصلاة القادمة',
        value: '--:--',
        subtitle: 'جاري الحساب...',
        icon: CupertinoIcons.clock,
        accentColor: const Color(0xFF007AFF),
        onTap: onTap ?? () {},
      );
    }

    final timeFormat = DateFormat('hh:mm a', 'ar_EG');
    final formattedTime = timeFormat.format(nextPrayer.prayerTime);
    final countdown = nextPrayer.formatRemainingCountdown();

    return SummaryCard(
      title: 'الصلاة القادمة',
      value: formattedTime,
      subtitle: '${nextPrayer.prayerNameArabic} • متبقي $countdown',
      icon: CupertinoIcons.sun_haze_fill,
      accentColor: const Color(0xFF007AFF),
      onTap: onTap ?? () {},
    );
  }
}
