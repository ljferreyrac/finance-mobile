import 'package:flutter/material.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

const List<String> kCategoryPresetColors = [
  '#16A34A',
  '#2563EB',
  '#DC2626',
  '#7C3AED',
  '#D97706',
  '#0891B2',
  '#DB2777',
  '#65A30D',
  '#6366F1',
  '#0D9488',
  '#6B7280',
];

/// Converts a hex color string (with or without leading #) to a [Color].
Color hexToColor(String hex) =>
    Color(int.parse(hex.replaceAll('#', '0xFF')));

/// Returns the selected hex color via [Navigator.pop], or null if dismissed.
Future<String?> showCategoryColorPicker(
  BuildContext context, {
  String? current,
}) {
  return showModalBottomSheet<String>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ColorPickerSheet(current: current),
  );
}

class _ColorPickerSheet extends StatelessWidget {
  const _ColorPickerSheet({this.current});

  final String? current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.chooseColor,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              physics: const NeverScrollableScrollPhysics(),
              children: kCategoryPresetColors.map((hex) {
                final isSelected =
                    hex.toLowerCase() == (current?.toLowerCase() ?? '');
                return GestureDetector(
                  onTap: () => Navigator.of(context).pop(hex),
                  child: Container(
                    decoration: BoxDecoration(
                      color: hexToColor(hex),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 3,
                            )
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
