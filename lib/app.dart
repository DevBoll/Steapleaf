import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/steapleaf_theme.dart';
import 'shell/main_shell.dart';

class SteapLeafApp extends StatelessWidget {
  const SteapLeafApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'SteapLeaf',
        debugShowCheckedModeBanner: false,
        theme: SteapLeafTheme.light,
        darkTheme: SteapLeafTheme.dark,
        themeMode: ThemeMode.system,
        home: const MainShell(),
      );
  }
}
