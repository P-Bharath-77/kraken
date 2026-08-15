import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'data/client_repository.dart';
import 'features/splash/splash_screen.dart';

class DndGymApp extends StatelessWidget {
  const DndGymApp({required this.repository, super.key});

  final ClientRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D&D Gym',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: SplashScreen(repository: repository),
    );
  }
}
