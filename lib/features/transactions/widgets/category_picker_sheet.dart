import 'package:flutter/material.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../../categories/models/category_model.dart';

/// Shows a modal bottom sheet listing [categories] for the user to pick one,
/// with a trailing row to create a new category.
///
/// Resolves with the selected [CategoryModel], or `null` if dismissed
/// without a selection.
Future<CategoryModel?> showCategoryPickerSheet(
  BuildContext context, {
  required List<CategoryModel> categories,
  required VoidCallback onNewCategory,
}) {
  return showModalBottomSheet<CategoryModel>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _CategoryPickerSheet(
      categories: categories,
      onNewCategory: onNewCategory,
    ),
  );
}

class _CategoryPickerSheet extends StatelessWidget {
  const _CategoryPickerSheet({
    required this.categories,
    required this.onNewCategory,
  });

  final List<CategoryModel> categories;
  final VoidCallback onNewCategory;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Text(
              AppLocalizations.of(context)!.selectCategory,
              style: textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (categories.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                AppLocalizations.of(context)!.noCategoriesAvailable,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (_, i) {
                  final category = categories[i];
                  final color = category.color != null
                      ? Color(
                          int.parse(
                            category.color!.replaceAll('#', '0xFF'),
                          ),
                        )
                      : colorScheme.primary;

                  return ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: category.icon != null
                          ? Text(category.icon!,
                              style: const TextStyle(fontSize: 16))
                          : Text(
                              category.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                    title: Text(category.name),
                    onTap: () => Navigator.of(context).pop(category),
                  );
                },
              ),
            ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.add, color: colorScheme.primary),
            title: Text(
              AppLocalizations.of(context)!.newCategory,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: onNewCategory,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
