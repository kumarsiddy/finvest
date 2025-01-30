import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Image.asset(
          'lib/assets/logo-white.png',
          width: 150,
        ),
      ),
    );
  }
}
