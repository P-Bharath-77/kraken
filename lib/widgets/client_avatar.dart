import 'dart:io';

import 'package:flutter/material.dart';

import '../core/theme.dart';

class ClientAvatar extends StatelessWidget {
  const ClientAvatar({required this.name, this.photoPath, this.radius = 28, super.key});

  final String name;
  final String? photoPath;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final file = photoPath == null ? null : File(photoPath!);
    final hasPhoto = file?.existsSync() ?? false;
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.surfaceHigh,
      foregroundColor: AppColors.gold,
      backgroundImage: hasPhoto ? FileImage(file!) : null,
      child: hasPhoto
          ? null
          : Text(
              name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase(),
              style: TextStyle(fontSize: radius * .7, fontWeight: FontWeight.bold),
            ),
    );
  }
}
