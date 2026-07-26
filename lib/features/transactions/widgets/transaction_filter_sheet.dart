import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../../../shared/widgets/filter_chip_row.dart';
import '../../accounts/bloc/account_bloc.dart';
import '../../accounts/bloc/account_event.dart';
import '../../accounts/bloc/account_state.dart';
import '../../categories/bloc/category_bloc.dart';
import '../../categories/bloc/category_event.dart';
import '../../categories/bloc/category_state.dart';
import '../bloc/tag_bloc.dart';
import '../bloc/tag_event.dart';
import '../bloc/tag_state.dart';
import '../bloc/transaction_event.dart';

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
                  FilterSection(
                    title: AppLocalizations.of(context)!.filterAccount,
                    child: AccountFilterChips(
                      selectedId: _pendingAccountId,
                      onSelected: (id) =>
                          setState(() => _pendingAccountId = id),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FilterSection(
                    title: AppLocalizations.of(context)!.filterCategory,
                    child: CategoryFilterChips(
                      selectedId: _pendingCategoryId,
                      onSelected: (id) =>
                          setState(() => _pendingCategoryId = id),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FilterSection(
                    title: AppLocalizations.of(context)!.filterTag,
                    child: TagFilterChips(
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

