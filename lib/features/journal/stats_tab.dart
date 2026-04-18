import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/enums/enums.dart';
import '../../theme/steapleaf_theme.dart';
import 'session_provider.dart';


class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(builder: (context, sessions, _) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(
          SteapLeafSpacing.md, SteapLeafSpacing.md,
          SteapLeafSpacing.md, SteapLeafSpacing.xxl,
        ),
        children: [
          _KpiBlock(sessions: sessions),
          const SizedBox(height: SteapLeafSpacing.xl),
          _SectionLabel('Aktivität (Tage)'),
          const SizedBox(height: SteapLeafSpacing.sectionLabelMarginBottom),
          _HeatmapWidget(data: sessions.heatmapData),
          const SizedBox(height: SteapLeafSpacing.xl),
          _SectionLabel('Sessions pro Monat'),
          const SizedBox(height: SteapLeafSpacing.sectionLabelMarginBottom),
          _BarChartWidget(data: sessions.byMonth),
          const SizedBox(height: SteapLeafSpacing.xl),
          _SectionLabel('Nach Teesorte'),
          const SizedBox(height: SteapLeafSpacing.sectionLabelMarginBottom),
          _PieChartWidget(data: sessions.byTeaType),
        ],
      );
    },);
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: SteapLeafTextTheme.sectionLabel.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
}

class _KpiBlock extends StatelessWidget {
  final SessionProvider sessions;
  const _KpiBlock({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(SteapLeafSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline, width: 1.0),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _Kpi(sessions.mostBrewedTea, 'Meistgebrühter Tee', flex: 2),
              const _Sep(),
              _Kpi(sessions.currentYearSessions.toString(), 'Sessions'),
            ],
          ),
          const SizedBox(height: SteapLeafSpacing.md),
          Row(
            children: [
              _Kpi(
                sessions.averageRating > 0
                    ? sessions.averageRating.toStringAsFixed(1)
                    : '–',
                'Ø Bewertung',
              ),
              const _Sep(),
              _Kpi(sessions.uniqueTeasCount.toString(), 'Teesorten'),
              const _Sep(),
              _Kpi(sessions.teaDaysCount.toString(), 'Tee-Tage'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  final String value;
  final String label;
  final int flex;
  const _Kpi(this.value, this.label, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.w200,
              color: colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: textTheme.labelSmall!.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Sep extends StatelessWidget {
  const _Sep();
  @override
  Widget build(BuildContext context) => Container(
        width: 0.5,
        height: 36,
        color: Theme.of(context).colorScheme.outlineVariant,
        margin: const EdgeInsets.symmetric(horizontal: SteapLeafSpacing.sm),
      );
}

// --- Heatmap ---

class _HeatmapWidget extends StatelessWidget {
  final Map<DateTime, int> data;
  const _HeatmapWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final days = now.difference(startOfYear).inDays + 1;
    final weeks = (days / 7).ceil();

    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(weeks, (w) {
          return Expanded(
            child: Column(
              children: List.generate(7, (d) {
                final dayOffset = w * 7 + d;
                if (dayOffset >= days) return const Expanded(child: SizedBox());
                final date = startOfYear.add(Duration(days: dayOffset));
                final key = DateTime(date.year, date.month, date.day);
                final count = data[key] ?? 0;

                Color color;
                if (count == 0) {
                  color = colorScheme.outlineVariant;
                } else if (count == 1) {
                  color = colorScheme.primary.withValues(alpha: 0.3);
                } else if (count == 2) {
                  color = colorScheme.primary.withValues(alpha: 0.55);
                } else {
                  color = colorScheme.primary;
                }

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(0.5),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}

// --- Balkendiagramm ---

class _BarChartWidget extends StatefulWidget {
  final Map<String, int> data;
  const _BarChartWidget({required this.data});

  @override
  State<_BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<_BarChartWidget> {
  int? _touchedIndex;

  static const _months = [
    '', 'Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun',
    'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez',
  ];
  static const _monthsShort = [
    '', 'J', 'F', 'M', 'A', 'M', 'J',
    'J', 'A', 'S', 'O', 'N', 'D',
  ];

  String _monthName(String key) {
    final parts = key.split('-');
    if (parts.length < 2) return '';
    final m = int.tryParse(parts[1]) ?? 0;
    return m >= 1 && m <= 12 ? _months[m] : '';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty || widget.data.values.every((v) => v == 0)) {
      return const _EmptyChart();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final entries = widget.data.entries.toList();
    final maxVal =
        entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 140,
      child: BarChart(
        BarChartData(
          maxY: (maxVal + 1).toDouble(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (_) => FlLine(
              color: colorScheme.outlineVariant,
              strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    response?.spot == null) {
                  _touchedIndex = null;
                  return;
                }
                _touchedIndex = response!.spot!.touchedBarGroupIndex;
              });
            },
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => colorScheme.onSurface,
              tooltipPadding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6,),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final key = entries[groupIndex].key;
                final count = rod.toY.round();
                return BarTooltipItem(
                  '${_monthName(key)}\n',
                  textTheme.labelSmall!.copyWith(
                    color: colorScheme.surface,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                  children: [
                    TextSpan(
                      text: count == 1 ? '1 Session' : '$count Sessions',
                      style: textTheme.bodySmall!.copyWith(
                        color: colorScheme.surface,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= entries.length) return const SizedBox();
                  final key = entries[i].key;
                  final parts = key.split('-');
                  if (parts.length < 2) return const SizedBox();
                  final month = int.tryParse(parts[1]) ?? 0;
                  final label = month >= 1 && month <= 12
                      ? _monthsShort[month]
                      : '';
                  return Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      color: i == _touchedIndex
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                      fontWeight: i == _touchedIndex
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  );
                },
                reservedSize: 18,
              ),
            ),
          ),
          barGroups: entries.asMap().entries.map((e) {
            final touched = e.key == _touchedIndex;
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value.toDouble(),
                  color: touched ? colorScheme.onSurface : colorScheme.primary,
                  width: touched ? 8 : 6,
                  borderRadius: BorderRadius.circular(1),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// --- Tortendiagramm ---

class _PieChartWidget extends StatefulWidget {
  final Map<TeaType, int> data;
  const _PieChartWidget({required this.data});

  @override
  State<_PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<_PieChartWidget> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final filtered =
        widget.data.entries.where((e) => e.value > 0).toList();
    if (filtered.isEmpty) return const _EmptyChart();

    final total =
        filtered.map((e) => e.value).reduce((a, b) => a + b);

    return Row(
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback:
                    (FlTouchEvent event, PieTouchResponse? response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response?.touchedSection == null) {
                      _touchedIndex = null;
                      return;
                    }
                    _touchedIndex =
                        response!.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: filtered.asMap().entries.map((e) {
                final i = e.key;
                final entry = e.value;
                final pct = entry.value / total * 100;
                final touched = i == _touchedIndex;
                return PieChartSectionData(
                  value: entry.value.toDouble(),
                  color: entry.key.color,
                  title: pct >= 10 ? '${pct.round()}%' : '',
                  titleStyle: TextStyle(
                      fontSize: 9,
                      color: entry.key.textColor,
                      fontWeight: FontWeight.w400,),
                  radius: touched ? 65 : 55,
                  borderSide: touched
                      ? BorderSide(color: colorScheme.onSurface, width: 1.5)
                      : BorderSide.none,
                );
              }).toList(),
              sectionsSpace: 1,
              centerSpaceRadius: 20,
            ),
          ),
        ),
        const SizedBox(width: SteapLeafSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: filtered.asMap().entries.map((e) {
              final i = e.key;
              final entry = e.value;
              final pct = (entry.value / total * 100).round();
              final touched = i == _touchedIndex;
              return InkWell(
                onTap: () =>
                    setState(() => _touchedIndex = touched ? null : i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: entry.key.color,
                          borderRadius: BorderRadius.circular(1),
                          border: touched
                              ? Border.all(
                                  color: colorScheme.onSurface, width: 1,)
                              : null,
                        ),
                      ),
                      const SizedBox(width: SteapLeafSpacing.tiny),
                      Expanded(
                        child: Text(
                          entry.key.label,
                          style: textTheme.labelSmall!.copyWith(
                            color: touched
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant,
                            fontWeight: touched
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      Text(
                        '$pct %',
                        style: textTheme.labelSmall!.copyWith(
                          color: touched
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                          fontWeight: touched
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 60,
        child: Center(
          child: Text(
            'Noch keine Daten',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
}
