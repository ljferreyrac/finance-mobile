import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';
import '../models/category_model.dart';
import '../widgets/category_color_picker.dart';
import 'category_form_screen.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../../shared/utils/localized_message_resolver.dart';

/// Full-page screen for managing the user's custom categories.
///
/// [CategoryBloc] must be provided above this route.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    final state = context.read<CategoryBloc>().state;
    if (state is CategoryInitial) {
      context.read<CategoryBloc>().add(const LoadCategories());
    }
  }

  Future<void> _openForm({CategoryModel? category}) async {
    final categoryBloc = context.read<CategoryBloc>();
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: categoryBloc,
          child: CategoryFormScreen(initialCategory: category),
        ),
      ),
    );
    if (result == true) {
      // No-op: the bloc already refreshed the list after the action.
    }
  }

  void _onSetDefault(CategoryModel category) {
    context
        .read<CategoryBloc>()
        .add(SetDefaultCategory(id: category.id));
  }

  Future<void> _onDelete(CategoryModel category, List<CategoryModel> all) async {
    if (category.expenseCount > 0) {
      final others = all.where((c) => c.id != category.id).toList();
      final reassignId = await _showReassignDialog(category, others);
      if (reassignId == null) return;
      if (!mounted) return;
      context.read<CategoryBloc>().add(
            DeleteCategory(id: category.id, reassignTo: reassignId),
          );
    } else {
      final confirmed = await _showConfirmDeleteDialog(category);
      if (confirmed != true) return;
      if (!mounted) return;
      context.read<CategoryBloc>().add(DeleteCategory(id: category.id));
    }
  }

  Future<bool?> _showConfirmDeleteDialog(CategoryModel category) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteCategoryTitle),
        content: Text(l10n.deleteCategoryConfirm(category.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  /// Returns the selected replacement category ID, or null if cancelled.
  Future<String?> _showReassignDialog(
    CategoryModel toDelete,
    List<CategoryModel> options,
  ) {
    final l10n = AppLocalizations.of(context)!;
    String? selected = options.firstOrNull?.id;
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: Text(l10n.reassignExpenses),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.reassignMessage(
                    toDelete.name, toDelete.expenseCount)),
                const SizedBox(height: 12),
                if (options.isEmpty)
                  Text(l10n.noOtherCategories)
                else
                  DropdownButton<String>(
                    isExpanded: true,
                    value: selected,
                    items: options.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      );
                    }).toList(),
                    onChanged: (v) => setDialogState(() => selected = v),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(null),
                child: Text(l10n.cancel),
              ),
              if (options.isNotEmpty)
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(ctx).colorScheme.error,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(selected),
                  child: Text(l10n.deleteAndReassign),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.categoriesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: AppLocalizations.of(context)!.newCategory,
            onPressed: () => _openForm(),
          ),
        ],
      ),
      body: BlocConsumer<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryActionSuccess) {
            AppSnackBar.showSuccess(
                context, state.message.resolve(AppLocalizations.of(context)!));
          }
          if (state is CategoryError) {
            AppSnackBar.showError(
              context,
              state.message.resolve(AppLocalizations.of(context)!),
              actionLabel: AppLocalizations.of(context)!.retry,
              onAction: () =>
                  context.read<CategoryBloc>().add(const LoadCategories()),
            );
          }
        },
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<CategoryModel> categories;
          if (state is CategoryLoaded) {
            categories = state.categories;
          } else if (state is CategoryActionSuccess) {
            categories = state.categories;
          } else if (state is CategoryError) {
            return _ErrorBody(
              message: state.message.resolve(AppLocalizations.of(context)!),
              onRetry: () =>
                  context.read<CategoryBloc>().add(const LoadCategories()),
            );
          } else {
            return const SizedBox.shrink();
          }

          if (categories.isEmpty) {
            return const _EmptyBody();
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: categories.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryListTile(
                category: category,
                onEdit: () => _openForm(category: category),
                onSetDefault: () => _onSetDefault(category),
                onDelete: () => _onDelete(category, categories),
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryListTile extends StatelessWidget {
  const _CategoryListTile({
    required this.category,
    required this.onEdit,
    required this.onSetDefault,
    required this.onDelete,
  });

  final CategoryModel category;
  final VoidCallback onEdit;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final circleColor = category.color != null
        ? hexToColor(category.color!)
        : const Color(0xFF6B7280);

    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: circleColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: category.icon != null
            ? Text(
                category.icon!,
                style: const TextStyle(fontSize: 20),
              )
            : Text(
                category.name.isNotEmpty
                    ? category.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
      ),
      title: Text(
        category.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: category.expenseCount > 0
          ? Text(AppLocalizations.of(context)!.expenseCount(category.expenseCount))
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (category.isDefault)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                AppLocalizations.of(context)!.defaultLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          PopupMenuButton<_MenuAction>(
            onSelected: (action) {
              switch (action) {
                case _MenuAction.edit:
                  onEdit();
                case _MenuAction.setDefault:
                  onSetDefault();
                case _MenuAction.delete:
                  onDelete();
              }
            },
            itemBuilder: (ctx) {
              final l10n = AppLocalizations.of(ctx)!;
              return [
                PopupMenuItem(
                  value: _MenuAction.edit,
                  child: Text(l10n.edit),
                ),
                if (!category.isDefault)
                  PopupMenuItem(
                    value: _MenuAction.setDefault,
                    child: Text(l10n.setAsDefault),
                  ),
                PopupMenuItem(
                  value: _MenuAction.delete,
                  child: Text(l10n.delete),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}

enum _MenuAction { edit, setDefault, delete }

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.emptyCategories,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }
}
