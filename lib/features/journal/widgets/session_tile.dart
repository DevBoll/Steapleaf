import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/session.dart';
import '../../../features/collection/tea_provider.dart';
import '../../../shared/widgets/star_rating.dart';
import '../../../shared/widgets/tea_thumb.dart';
import '../../../shared/widgets/tea_type_chip.dart';
import '../../../theme/steapleaf_theme.dart';
import '../session_detail_screen.dart';


/// Vollständige Session-Zeile mit Typ-Kreis, Name, Typ-Chip,
/// Datum, Bewertung und Aufguss-Anzahl.
///
/// Verwendet in HistoryTab. Beim Antippen wird [SessionDetailScreen] geöffnet.
class SessionTile extends StatelessWidget {
  final Session session;

  const SessionTile(this.session, {super.key});

  static final _df = DateFormat('dd.MM.yy · HH:mm');

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tea = session.teaId != null
        ? context.watch<TeaProvider>().getById(session.teaId!)
        : null;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => SessionDetailScreen(session: session),),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SteapLeafSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (tea != null)
              TeaThumb(tea: tea, size: 60)
            else
              CircleAvatar(
                radius: 30,
                backgroundColor: session.teaType.colors.container,
                child: Text(
                  session.teaType.kanji,
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 24,
                    color: session.teaType.colors.onContainer,
                    fontWeight: FontWeight.w400,
                    height: 1.0,
                  ),
                ),
              ),
            const SizedBox(width: SteapLeafSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(session.teaName, style: textTheme.titleMedium),
                  const SizedBox(height: SteapLeafSpacing.tiny),
                  Row(
                    children: [
                      TeaTypeChip(type: session.teaType),
                      const SizedBox(width: SteapLeafSpacing.xs),
                      Expanded(
                        child: Text(
                          _df.format(session.dateTime).toUpperCase(),
                          style: SteapLeafTextTheme.sectionLabel.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Visibility(
                  visible: session.rating > 0,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: StarRating(
                    rating: session.rating > 0 ? session.rating : 1,
                    size: 11,
                  ),
                ),
                const SizedBox(height: SteapLeafSpacing.tiny),
                Visibility(
                  visible: session.infusionLogs.isNotEmpty,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Text(
                    '${session.infusionLogs.length}×',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
