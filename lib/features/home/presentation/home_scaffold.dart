import 'package:flutter/cupertino.dart';
import 'package:jimy/features/week/presentation/week_screen.dart';

/// Root home scaffold displaying the 7-column Week board as the primary view.
class HomeScaffold extends StatelessWidget {
  const HomeScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return const WeekScreen();
  }
}
