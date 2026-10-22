import 'package:flutter/cupertino.dart';
import 'package:jimy/features/settings/presentation/settings_screen.dart';
import 'package:jimy/features/today/presentation/today_screen.dart';
import 'package:jimy/features/week/presentation/week_screen.dart';
import 'package:jimy/l10n/app_localizations.dart';

class HomeScaffold extends StatelessWidget {
  const HomeScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabBarBg = CupertinoColors.systemBackground.resolveFrom(context).withValues(alpha: 0.92);

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: tabBarBg,
        activeColor: CupertinoColors.systemBlue,
        inactiveColor: CupertinoColors.systemGrey,
        border: Border(
          top: BorderSide(
            color: CupertinoColors.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.sun_max),
            activeIcon: const Icon(CupertinoIcons.sun_max_fill),
            label: l10n.todayTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.calendar),
            activeIcon: const Icon(CupertinoIcons.calendar_today),
            label: l10n.weekTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.gear),
            activeIcon: const Icon(CupertinoIcons.gear_solid),
            label: l10n.settingsTab,
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) => const TodayScreen(),
            );
          case 1:
            return CupertinoTabView(
              builder: (context) => const WeekScreen(),
            );
          case 2:
            return CupertinoTabView(
              builder: (context) => const SettingsScreen(),
            );
          default:
            return CupertinoTabView(
              builder: (context) => const TodayScreen(),
            );
        }
      },
    );
  }
}
