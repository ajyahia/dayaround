import 'package:flutter/cupertino.dart';
import 'package:jimy/features/today/presentation/today_screen.dart';

/// Clean Apple Reminders root scaffold without obsolete bottom tab bar.
class HomeScaffold extends StatelessWidget {
  const HomeScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return const TodayScreen();
  }
}
