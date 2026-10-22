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

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.sun_max),
            activeIcon: const Icon(CupertinoIcons.sun_max_fill),
            label: l10n.todayTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.calendar),
            label: l10n.weekTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.settings),
            activeIcon: const Icon(CupertinoIcons.settings_solid),
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
