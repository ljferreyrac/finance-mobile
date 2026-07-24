import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../../accounts/bloc/account_bloc.dart';
import '../../accounts/bloc/account_event.dart';
import '../../accounts/bloc/account_state.dart';
import '../../accounts/models/account_model.dart';
import '../../categories/bloc/category_bloc.dart';
import '../../categories/bloc/category_event.dart';
import '../../categories/bloc/category_state.dart';
import '../../categories/models/category_model.dart';
import '../../categories/widgets/category_color_picker.dart';
import '../bloc/tag_bloc.dart';
import '../bloc/tag_event.dart';
import '../bloc/tag_state.dart';
import '../bloc/transaction_event.dart';
import '../models/tag_model.dart';

/// Opens a modal bottom sheet for filtering transactions by account, category,
/// and tag. The sheet manages its own pending selection state as a
/// [StatefulWidget]; the committed filter is only returned when the user taps
/// "Aplicar".
///
/// Returns a [TransactionFilter] with account/category/tag fields updated. The
/// [type] field from [current] is always preserved unchanged.
///
/// Usage:
/// ```dart
/// final result = await showTransactionFilterSheet(context, current: _activeFilter);
/// if (result != null) {
///   context.read<TransactionBloc>().add(ApplyFilter(result));
/// }
/// ```
Future<TransactionFilter?> showTransactionFilterSheet(
  BuildContext context, {
  required TransactionFilter current,
}) {
  final accountBloc = context.read<AccountBloc>();
  final categoryBloc = context.read<CategoryBloc>();
  final tagBloc = context.read<TagBloc>();

  return showModalBottomSheet<TransactionFilter>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: accountBloc),
        BlocProvider.value(value: categoryBloc),
        BlocProvider.value(value: tagBloc),
      ],
      child: _TransactionFilterSheet(current: current),
    ),
  );
}

class _TransactionFilterSheet extends StatefulWidget {
  const _TransactionFilterSheet({required this.current});

  final TransactionFilter current;

  @override
  State<_TransactionFilterSheet> createState() =>
      _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<_TransactionFilterSheet> {
  // Pending selections that are committed only when the user taps "Aplicar".
  String? _pendingAccountId;
  String? _pendingCategoryId;
  String? _pendingTagId;

  @override
  void initState() {
    super.initState();
    _pendingAccountId = widget.current.accountId;
    _pendingCategoryId = widget.current.categoryId;
    _pendingTagId = widget.current.tagId;

    final accountState = context.read<AccountBloc>().state;
    if (accountState is AccountInitial) {
      context.read<AccountBloc>().add(const LoadAccounts());
    }

    final categoryState = context.read<CategoryBloc>().state;
    if (categoryState is CategoryInitial) {
      context.read<CategoryBloc>().add(const LoadCategories());
    }

    final tagState = context.read<TagBloc>().state;
    if (tagState is TagInitial) {
      context.read<TagBloc>().add(const LoadTags());
    }
  }

  void _clearAll() {
    setState(() {
      _pendingAccountId = null;
      _pendingCategoryId = null;
      _pendingTagId = null;
    });
  }

  void _apply() {
    final result = widget.current.copyWith(
      clearAccountId: _pendingAccountId == null,
      clearCategoryId: _pendingCategoryId == null,
      clearTagId: _pendingTagId == null,
      accountId: _pendingAccountId,
      categoryId: _pendingCategoryId,
      tagId: _pendingTagId,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.filterTitle,
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: AppLocalizations.of(context)!.closeTooltip,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.55,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FilterSection(
                    title: AppLocalizations.of(context)!.filterAccount,
                    child: _AccountChips(
                      selectedId: _pendingAccountId,
                      onSelected: (id) =>
                          setState(() => _pendingAccountId = id),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _FilterSection(
                    title: AppLocalizations.of(context)!.filterCategory,
                    child: _CategoryChips(
                      selectedId: _pendingCategoryId,
                      onSelected: (id) =>
                          setState(() => _pendingCategoryId = id),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _FilterSection(
                    title: AppLocalizations.of(context)!.filterTag,
                    child: _TagChips(
                      selectedId: _pendingTagId,
                      onSelected: (id) => setState(() => _pendingTagId = id),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearAll,
                    child: Text(AppLocalizations.of(context)!.clearFilters),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _apply,
                    child: Text(AppLocalizations.of(context)!.applyFilters),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
          ),
        ),
        child,
      ],
    );
  }
}

class _AccountChips extends StatelessWidget {
  const _AccountChips({
    required this.selectedId,
    required this.onSelected,
  });

  final String? selectedId;
  final void Function(String? id) onSelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        if (state is AccountLoading) {
          return const _ChipsLoadingPlaceholder();
        }

        List<AccountModel> accounts = const [];
        if (state is AccountLoaded) {
          accounts = state.accounts;
        } else if (state is AccountOperationSuccess) {
          accounts = state.accounts;
        }

        if (accounts.isEmpty) {
          return _ChipsEmptyPlaceholder(message: AppLocalizations.of(context)!.noAccounts);
        }

        return _HorizontalChipRow(
          children: accounts.map((account) {
            final isSelected = account.id == selectedId;
            return _FilterChip(
              label: account.name,
              isSelected: isSelected,
              dotColor: account.color != null
                  ? hexToColor(account.color!)
                  : null,
              onTap: () => onSelected(isSelected ? null : account.id),
            );
          }).toList(),
        );
      },
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.selectedId,
    required this.onSelected,
  });

  final String? selectedId;
  final void Function(String? id) onSelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const _ChipsLoadingPlaceholder();
        }

        List<CategoryModel> categories = const [];
        if (state is CategoryLoaded) {
          categories = state.categories;
        } else if (state is CategoryActionSuccess) {
          categories = state.categories;
        }

        if (categories.isEmpty) {
          return _ChipsEmptyPlaceholder(message: AppLocalizations.of(context)!.noCategories);
        }

        return _HorizontalChipRow(
          children: categories.map((category) {
            final isSelected = category.id == selectedId;
            return _FilterChip(
              label: category.name,
              isSelected: isSelected,
              dotColor: category.color != null
                  ? hexToColor(category.color!)
                  : null,
              onTap: () => onSelected(isSelected ? null : category.id),
            );
          }).toList(),
        );
      },
    );
  }
}

class _TagChips extends StatelessWidget {
  const _TagChips({
    required this.selectedId,
    required this.onSelected,
  });

  final String? selectedId;
  final void Function(String? id) onSelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TagBloc, TagState>(
      builder: (context, state) {
        if (state is TagLoading) {
          return const _ChipsLoadingPlaceholder();
        }

        List<TagModel> tags = const [];
        if (state is TagLoaded) {
          tags = state.tags;
        }

        if (tags.isEmpty) {
          return _ChipsEmptyPlaceholder(message: AppLocalizations.of(context)!.noTags);
        }

        return _HorizontalChipRow(
          children: tags.map((tag) {
            final isSelected = tag.id == selectedId;
            return _FilterChip(
              label: tag.name,
              isSelected: isSelected,
              dotColor: tag.color != null ? hexToColor(tag.color!) : null,
              onTap: () => onSelected(isSelected ? null : tag.id),
            );
          }).toList(),
        );
      },
    );
  }
}

class _HorizontalChipRow extends StatelessWidget {
  const _HorizontalChipRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: children
            .expand((chip) => [chip, const SizedBox(width: 8)])
            .toList()
          ..removeLast(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.dotColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  /// Optional colored dot shown to the left of the label (used for categories
  /// and accounts that carry a hex color).
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primary : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: colorScheme.outlineVariant, width: 0.75),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withValues(alpha: 0.85) : dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected ? Colors.white : colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipsLoadingPlaceholder extends StatelessWidget {
  const _ChipsLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: SizedBox(
        height: 32,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}

class _ChipsEmptyPlaceholder extends StatelessWidget {
  const _ChipsEmptyPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
