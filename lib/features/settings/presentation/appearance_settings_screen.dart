import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimy/core/theme/app_theme.dart';
import 'package:jimy/l10n/app_localizations.dart';

class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentMode = ref.watch(themeModeProvider);
    final cardBg = CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context);
    final separatorColor = CupertinoColors.separator.resolveFrom(context);
    final secondaryColor = CupertinoColors.secondaryLabel.resolveFrom(context);
    final labelColor = CupertinoColors.label.resolveFrom(context);

    final options = [
      (mode: AppThemeMode.system, title: l10n.themeSystem),
      (mode: AppThemeMode.light, title: l10n.themeLight),
      (mode: AppThemeMode.dark, title: l10n.themeDark),
    ];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(l10n.appearance),
        previousPageTitle: l10n.settingsTab,
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: cardBg,
                  child: Column(
                    children: [
                      for (int i = 0; i < options.length; i++) ...[
                        GestureDetector(
                          onTap: () {
                            ref.read(themeModeProvider.notifier).setThemeMode(options[i].mode);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 46),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      options[i].title,
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: labelColor,
                                      ),
                                    ),
                                  ),
                                  if (currentMode == options[i].mode)
                                    const Icon(
                                      CupertinoIcons.checkmark,
                                      size: 18,
                                      color: CupertinoColors.systemBlue,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (i < options.length - 1)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(start: 16),
                            child: Container(
                              height: 0.5,
                              color: separatorColor,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
              child: Text(
                l10n.appearanceFooter,
                style: TextStyle(
                  fontSize: 13,
                  color: secondaryColor,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
