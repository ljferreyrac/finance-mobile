import 'package:flutter/material.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

const List<String> kCategoryPresetIcons = [
  '\u{1F354}', // burger
  '\u{1F697}', // car
  '\u{1F48A}', // pill
  '\u{1F3AC}', // clapper board
  '\u{1F4A1}', // light bulb
  '\u{1F4DA}', // books
  '\u{1F455}', // t-shirt
  '\u{1F3E0}', // house
  '\u{1F4BB}', // laptop
  '\u2708\uFE0F', // airplane
  '\u{1F6D2}', // shopping cart
  '\u{1F43E}', // paw prints
  '\u{1F3AE}', // video game
  '\u{1F4B0}', // money bag
  '\u{1F381}', // gift
  '\u{1F3CB}\uFE0F', // weightlifter
];

/// Returns the selected emoji via [Navigator.pop], or null if dismissed.
Future<String?> showCategoryIconPicker(
  BuildContext context, {
  String? current,
}) {
  return showModalBottomSheet<String>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _IconPickerSheet(current: current),
  );
}

class _IconPickerSheet extends StatelessWidget {
  const _IconPickerSheet({this.current});

  final String? current;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.chooseIcon,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 6,
              shrinkWrap: true,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              physics: const NeverScrollableScrollPhysics(),
              children: kCategoryPresetIcons.map((emoji) {
                final isSelected = emoji == current;
                return GestureDetector(
                  onTap: () => Navigator.of(context).pop(emoji),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(
                              color: colorScheme.primary,
                              width: 2,
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
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
