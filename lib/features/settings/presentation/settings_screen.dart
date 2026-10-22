import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimy/core/theme/app_theme.dart';
import 'package:jimy/core/widgets/settings_row.dart';
import 'package:jimy/features/settings/presentation/appearance_settings_screen.dart';
import 'package:jimy/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _getThemeTitle(AppThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case AppThemeMode.system:
        return l10n.themeSystem;
      case AppThemeMode.light:
        return l10n.themeLight;
      case AppThemeMode.dark:
        return l10n.themeDark;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider);
    final cardBg = CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context);
    final separatorColor = CupertinoColors.separator.resolveFrom(context);
    final footerColor = CupertinoColors.secondaryLabel.resolveFrom(context);

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(l10n.settingsTab),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  // Section 1: Appearance
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: cardBg,
                        child: SettingsRow(
                          icon: CupertinoIcons.circle_righthalf_fill,
                          iconBackgroundColor: CupertinoColors.systemBlue,
                          title: l10n.appearance,
                          value: _getThemeTitle(themeMode, l10n),
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => const AppearanceSettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section 2: Prayer & Planner Configuration
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: cardBg,
                        child: Column(
                          children: [
                            SettingsRow(
                              icon: CupertinoIcons.location_fill,
                              iconBackgroundColor: CupertinoColors.systemGreen,
                              title: l10n.location,
                              value: l10n.soon,
                              onTap: () {},
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.only(start: 57),
                              child: Container(height: 0.5, color: separatorColor),
                            ),
                            SettingsRow(
                              icon: CupertinoIcons.compass_fill,
                              iconBackgroundColor: CupertinoColors.systemOrange,
                              title: l10n.calcMethod,
                              value: l10n.soon,
                              onTap: () {},
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.only(start: 57),
                              child: Container(height: 0.5, color: separatorColor),
                            ),
                            SettingsRow(
                              icon: CupertinoIcons.clock_fill,
                              iconBackgroundColor: CupertinoColors.systemTeal,
                              title: l10n.asrMadhab,
                              value: l10n.soon,
                              onTap: () {},
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.only(start: 57),
                              child: Container(height: 0.5, color: separatorColor),
                            ),
                            SettingsRow(
                              icon: CupertinoIcons.calendar,
                              iconBackgroundColor: CupertinoColors.systemIndigo,
                              title: l10n.weekStart,
                              value: l10n.soon,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Privacy Footer
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    child: Text(
                      l10n.privacyNote,
                      style: TextStyle(
                        fontSize: 13,
                        color: footerColor,
                        height: 1.35,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
