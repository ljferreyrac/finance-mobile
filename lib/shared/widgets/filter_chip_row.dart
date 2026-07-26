import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../../features/accounts/bloc/account_bloc.dart';
import '../../features/accounts/bloc/account_state.dart';
import '../../features/accounts/models/account_model.dart';
import '../../features/categories/bloc/category_bloc.dart';
import '../../features/categories/bloc/category_state.dart';
import '../../features/categories/models/category_model.dart';
import '../../features/categories/widgets/category_color_picker.dart';
import '../../features/transactions/bloc/tag_bloc.dart';
import '../../features/transactions/bloc/tag_state.dart';
import '../../features/transactions/models/tag_model.dart';

/// A labeled section within a filter sheet, wrapping a horizontally
/// scrolling row of selectable chips (e.g. accounts, categories, tags).
class FilterSection extends StatelessWidget {
  const FilterSection({super.key, required this.title, required this.child});

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

/// Row of [SelectableFilterChip]s built from the current [AccountBloc]
/// state. Shows a loading placeholder while accounts load and an empty
/// placeholder when there are none.
class AccountFilterChips extends StatelessWidget {
  const AccountFilterChips({
    super.key,
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
          return const ChipsLoadingPlaceholder();
        }

        List<AccountModel> accounts = const [];
        if (state is AccountLoaded) {
          accounts = state.accounts;
        } else if (state is AccountOperationSuccess) {
          accounts = state.accounts;
        }

        if (accounts.isEmpty) {
          return ChipsEmptyPlaceholder(
            message: AppLocalizations.of(context)!.noAccounts,
          );
        }

        return HorizontalChipRow(
          children: accounts.map((account) {
            final isSelected = account.id == selectedId;
            return SelectableFilterChip(
              label: account.name,
              isSelected: isSelected,
              dotColor:
                  account.color != null ? hexToColor(account.color!) : null,
              onTap: () => onSelected(isSelected ? null : account.id),
            );
          }).toList(),
        );
      },
    );
  }
}

/// Row of [SelectableFilterChip]s built from the current [CategoryBloc]
/// state. Shows a loading placeholder while categories load and an empty
/// placeholder when there are none.
class CategoryFilterChips extends StatelessWidget {
  const CategoryFilterChips({
    super.key,
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
          return const ChipsLoadingPlaceholder();
        }

        List<CategoryModel> categories = const [];
        if (state is CategoryLoaded) {
          categories = state.categories;
        } else if (state is CategoryActionSuccess) {
          categories = state.categories;
        }

        if (categories.isEmpty) {
          return ChipsEmptyPlaceholder(
            message: AppLocalizations.of(context)!.noCategories,
          );
        }

        return HorizontalChipRow(
          children: categories.map((category) {
            final isSelected = category.id == selectedId;
            return SelectableFilterChip(
              label: category.name,
              isSelected: isSelected,
              dotColor:
                  category.color != null ? hexToColor(category.color!) : null,
              onTap: () => onSelected(isSelected ? null : category.id),
            );
          }).toList(),
        );
      },
    );
  }
}

/// Row of [SelectableFilterChip]s built from the current [TagBloc] state.
/// Shows a loading placeholder while tags load and an empty placeholder
/// when there are none.
class TagFilterChips extends StatelessWidget {
  const TagFilterChips({
    super.key,
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
          return const ChipsLoadingPlaceholder();
        }

        List<TagModel> tags = const [];
        if (state is TagLoaded) {
          tags = state.tags;
        }

        if (tags.isEmpty) {
          return ChipsEmptyPlaceholder(
            message: AppLocalizations.of(context)!.noTags,
          );
        }

        return HorizontalChipRow(
          children: tags.map((tag) {
            final isSelected = tag.id == selectedId;
            return SelectableFilterChip(
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

/// Horizontally scrolling row of chips with a fixed gap between them.
class HorizontalChipRow extends StatelessWidget {
  const HorizontalChipRow({super.key, required this.children});

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

/// A single filter chip: a pill that fills solid when [isSelected], with an
/// optional colored dot to the left of the label (used for categories and
/// accounts that carry a hex color).
class SelectableFilterChip extends StatelessWidget {
  const SelectableFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.dotColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
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
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.85)
                      : dotColor,
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

class ChipsLoadingPlaceholder extends StatelessWidget {
  const ChipsLoadingPlaceholder({super.key});

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

class ChipsEmptyPlaceholder extends StatelessWidget {
  const ChipsEmptyPlaceholder({super.key, required this.message});

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
