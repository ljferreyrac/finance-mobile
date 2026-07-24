import 'package:flutter/material.dart';

import '../models/tag_model.dart';

/// Renders a [TagModel] as a compact chip.
///
/// When [color] is set on the tag, it is used as the chip background with
/// automatically contrasted label text. When absent, the chip falls back to
/// the theme's default surface-variant style.
///
/// Provide [onDeleted] to render a dismiss icon on the right side of the chip
/// (useful in edit mode).
class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.tag,
    this.onDeleted,
  });

  final TagModel tag;

  /// When non-null, an X icon is shown and this callback fires on tap.
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (tag.color != null) {
      final bgColor = _hexToColor(tag.color!);
      final labelColor = _contrastColor(bgColor);

      return Chip(
        label: Text(
          tag.name,
          style: TextStyle(
            color: labelColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: bgColor,
        deleteIconColor: labelColor,
        onDeleted: onDeleted,
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      );
    }

    // Default neutral style: follows surface variant.
    return Chip(
      label: Text(
        tag.name,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: colorScheme.surfaceContainerHighest,
      deleteIconColor: colorScheme.onSurfaceVariant,
      onDeleted: onDeleted,
      side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  /// Parses a "#RRGGBB" hex string into a [Color].
  static Color _hexToColor(String hex) =>
      Color(int.parse('0xFF${hex.replaceAll('#', '')}'));

  /// Returns white or black depending on the luminance of [bg], ensuring
  /// WCAG AA contrast on the chip label.
  static Color _contrastColor(Color bg) {
    // Relative luminance per WCAG 2.1 formula.
    final r = (bg.r * 255.0).round().clamp(0, 255) / 255;
    final g = (bg.g * 255.0).round().clamp(0, 255) / 255;
    final b = (bg.b * 255.0).round().clamp(0, 255) / 255;
    final luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b;
    return luminance > 0.35 ? Colors.black87 : Colors.white;
  }
}
