import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../models/monthly_report_model.dart';

/// Category color palette consistent with the app theme (#1D9E75).
const List<Color> categoryColors = [
  Color(0xFF1D9E75),
  Color(0xFF2196F3),
  Color(0xFFFF9800),
  Color(0xFFE91E63),
  Color(0xFF9C27B0),
  Color(0xFF00BCD4),
  Color(0xFFFFEB3B),
  Color(0xFF795548),
  Color(0xFF607D8B),
  Color(0xFF4CAF50),
  Color(0xFF9E9E9E),
];

/// Pie chart of expense distribution by category, with a color-coded
/// legend below it.
class CategoryChart extends StatefulWidget {
  const CategoryChart({
    super.key,
    required this.categories,
  });

  final List<CategoryBreakdown> categories;

  @override
  State<CategoryChart> createState() => _CategoryChartState();
}

class _CategoryChartState extends State<CategoryChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return _emptyState(context);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.byCategory,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex = pieTouchResponse
                          .touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: _buildSections(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(context),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return List.generate(widget.categories.length, (index) {
      final cat = widget.categories[index];
      final isTouched = index == _touchedIndex;
      final radius = isTouched ? 60.0 : 50.0;
      final color = categoryColors[index % categoryColors.length];

      return PieChartSectionData(
        color: color,
        value: cat.percentage,
        title: isTouched ? '${cat.percentage.toStringAsFixed(1)}%' : '',
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildLegend(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: List.generate(widget.categories.length, (index) {
        final cat = widget.categories[index];
        final color = categoryColors[index % categoryColors.length];
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${cat.label} ${cat.percentage.toStringAsFixed(1)}%',
              style: textTheme.labelSmall,
            ),
          ],
        );
      }),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Text(
          AppLocalizations.of(context)!.noDataPeriod,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}
