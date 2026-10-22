import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimy/core/theme/app_theme.dart';
import 'package:jimy/features/home/presentation/home_scaffold.dart';
import 'package:jimy/l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: JimyApp(),
    ),
  );
}

class JimyApp extends ConsumerWidget {
  const JimyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return CupertinoApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(themeMode),
      locale: const Locale('ar', 'EG'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();

        if (kIsWeb) {
          final isDark = themeMode == AppThemeMode.dark ||
              (themeMode == AppThemeMode.system &&
                  MediaQuery.platformBrightnessOf(context) == Brightness.dark);

          return ColoredBox(
            color: isDark ? const Color(0xFF141416) : const Color(0xFFE5E5EA),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? const Color(0x88000000)
                            : const Color(0x28000000),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipRect(child: child),
                ),
              ),
            ),
          );
        }
        return child;
      },
      home: const HomeScaffold(),
    );
  }
}
