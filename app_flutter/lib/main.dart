import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const PlayKeeperApp());
}

class PlayKeeperApp extends StatelessWidget {
  const PlayKeeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlayKeeper', // <-- O NOME NOVO AQUI!
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
    );
  }
}
