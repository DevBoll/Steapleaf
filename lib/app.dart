import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/repositories/sqlite_session_repository.dart';
import 'data/repositories/sqlite_tea_repository.dart';
import 'features/collection/tea_provider.dart';
import 'features/journal/session_provider.dart';
import 'theme/steapleaf_theme.dart';
import 'shell/main_shell.dart';

class SteapLeafApp extends StatelessWidget {
  const SteapLeafApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TeaProvider(const SqliteTeaRepository())
            ..loadAll(),
        ),
        ChangeNotifierProvider(
          create: (_) => SessionProvider(const SqliteSessionRepository())
            ..load(),
        ),
      ],
      child: MaterialApp(
        title: 'SteapLeaf',
        debugShowCheckedModeBanner: false,
        theme: SteapLeafTheme.light,
        darkTheme: SteapLeafTheme.dark,
        themeMode: ThemeMode.system,
        home: const MainShell(),
      ),
    );
  }
}
