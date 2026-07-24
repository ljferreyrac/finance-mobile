import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../../accounts/bloc/account_bloc.dart';
import '../../accounts/bloc/account_state.dart';
import '../../accounts/models/account_model.dart';
import '../../categories/bloc/category_bloc.dart';
import '../../categories/bloc/category_state.dart';
import '../../categories/models/category_model.dart';
import '../../transactions/bloc/tag_bloc.dart';
import '../../transactions/bloc/tag_state.dart';
import '../../transactions/models/tag_model.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';

/// Shows dismissible chips for active report filters; removing a chip clears
/// only that dimension via [ApplyReportFilter]. Renders nothing when no
/// filter is active. Requires [ReportBloc], [AccountBloc], [CategoryBloc],
/// and [TagBloc] above it in the tree.
class ActiveReportFiltersRow extends StatelessWidget {
  const ActiveReportFiltersRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, _) {
        final reportBloc = context.read<ReportBloc>();
        final accountId = reportBloc.currentAccountId;
        final categoryId = reportBloc.currentCategoryId;
        final tagId = reportBloc.currentTagId;

        if (accountId == null && categoryId == null && tagId == null) {
          return const SizedBox.shrink();
        }

        final chips = <Widget>[];

        if (accountId != null) {
          final name = _resolveAccountName(context, accountId);
          chips.add(_ActiveFilterChip(
            label: name ?? AppLocalizations.of(context)!.filterAccount,
            onRemove: () => context.read<ReportBloc>().add(ApplyReportFilter(
                  accountId: null,
                  categoryId: categoryId,
                  tagId: tagId,
                )),
          ));
        }

        if (categoryId != null) {
          final name = _resolveCategoryName(context, categoryId);
          chips.add(_ActiveFilterChip(
            label: name ?? AppLocalizations.of(context)!.filterCategory,
            onRemove: () => context.read<ReportBloc>().add(ApplyReportFilter(
                  accountId: accountId,
                  categoryId: null,
                  tagId: tagId,
                )),
          ));
        }

        if (tagId != null) {
          final name = _resolveTagName(context, tagId);
          chips.add(_ActiveFilterChip(
            label: name ?? AppLocalizations.of(context)!.filterTag,
            onRemove: () => context.read<ReportBloc>().add(ApplyReportFilter(
                  accountId: accountId,
                  categoryId: categoryId,
                  tagId: null,
                )),
          ));
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: chips
                .expand((chip) => [chip, const SizedBox(width: 8)])
                .toList()
              ..removeLast(),
          ),
        );
      },
    );
  }

  String? _resolveAccountName(BuildContext context, String id) {
    final state = context.read<AccountBloc>().state;
    List<AccountModel> accounts = const [];
    if (state is AccountLoaded) {
      accounts = state.accounts;
    } else if (state is AccountOperationSuccess) {
      accounts = state.accounts;
    }
    try {
      return accounts.firstWhere((a) => a.id == id).name;
    } catch (_) {
      return null;
    }
  }

  String? _resolveCategoryName(BuildContext context, String id) {
    final state = context.read<CategoryBloc>().state;
    List<CategoryModel> categories = const [];
    if (state is CategoryLoaded) {
      categories = state.categories;
    } else if (state is CategoryActionSuccess) {
      categories = state.categories;
    }
    try {
      return categories.firstWhere((c) => c.id == id).name;
    } catch (_) {
      return null;
    }
  }

  String? _resolveTagName(BuildContext context, String id) {
    final state = context.read<TagBloc>().state;
    List<TagModel> tags = const [];
    if (state is TagLoaded) {
      tags = state.tags;
    }
    try {
      return tags.firstWhere((t) => t.id == id).name;
    } catch (_) {
      return null;
    }
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({
    required this.label,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
