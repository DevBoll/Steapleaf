import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/steapleaf_theme.dart';
import 'history_tab.dart';
import 'manual_session_screen.dart';
import 'session_provider.dart';
import 'stats_tab.dart';


class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() {
      if (_tabs.indexIsChanging) return;
      setState(() => _tabIndex = _tabs.index);
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SessionProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      floatingActionButton: _tabIndex == 1
          ? FloatingActionButton(
              heroTag: 'journal_fab',
              tooltip: 'Session manuell erfassen',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ManualSessionScreen()),
              ),
              child: Text(
                SteapLeafKanji.journal.character,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
            )
          : null,
      appBar: AppBar(
        title: Text('録 · Journal', style: textTheme.titleLarge),
        actions: [
          _AppBarStat(
            icon: Icons.history_outlined,
            iconColor: colorScheme.primary,
            count: provider.sessions.length,
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            _TabLabel('評', 'Auswertung', hasDot: false),
            _TabLabel('歴', 'Verlauf', hasDot: false),
          ])
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(
              child: Form(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    StatsTab(),
                    HistoryTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}

class _AppBarStat extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final int count;

  const _AppBarStat({
    required this.icon,
    required this.count,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = iconColor ?? colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 3),
          Text(
            '$count',
            style: textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  final String kanji;
  final String label;
  final bool hasDot;

  const _TabLabel(this.kanji, this.label, {required this.hasDot});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$kanji · $label'),
          if (hasDot) ...[
            const SizedBox(width: 5),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}