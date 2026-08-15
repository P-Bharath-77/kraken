import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/client_repository.dart';
import '../shell/app_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({required this.repository, super.key});
  final ClientRepository repository;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (_, animation, __) => FadeTransition(
            opacity: animation,
            child: AppShell(repository: widget.repository),
          ),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -.25),
              radius: .9,
              colors: [Color(0xFF30270B), AppColors.background],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.gold, width: 2),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(Icons.fitness_center, size: 48, color: AppColors.gold),
                ),
                const SizedBox(height: 24),
                const Text('D&D GYM', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: 4)),
                const SizedBox(height: 8),
                const Text('BUILD  •  DISCIPLINE  •  DOMINATE', style: TextStyle(color: AppColors.goldLight, fontSize: 11, letterSpacing: 1.8)),
              ],
            ),
          ),
        ),
      );
}
