import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../shared/utils/currency_formatter.dart';
import '../../accounts/bloc/account_bloc.dart';
import '../../categories/bloc/category_bloc.dart';
import '../bloc/tag_bloc.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../data/transaction_api_service.dart';
import '../models/transaction_model.dart';
import '../models/tag_model.dart';
import '../widgets/tag_chip.dart';
import 'transaction_form_screen.dart';
import '../../../core/widgets/app_snack_bar.dart';

/// Read-only detail view of a single transaction.
///
/// Provides edit (navigates to form pre-filled) and delete actions.
class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    return Scaffold(
      appBar: AppBar(
        title: Text(transaction.type.localizedLabel(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.editTooltip,
            onPressed: () => _openEdit(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.deleteTooltip,
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionOperationSuccess) {
            Navigator.of(context).pop();
          }
          if (state is TransactionError) {
            AppSnackBar.showError(context, state.message);
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _AmountHero(transaction: transaction),
            const SizedBox(height: 24),
            _DetailCard(
              children: [
                _DetailRow(
                  label: l10n.typeLabel,
                  value: transaction.type.localizedLabel(context),
                ),
                _DetailRow(
                  label: l10n.dateDetailLabel,
                  value: DateFormat('dd/MM/yyyy', locale)
                      .format(transaction.transactionDate),
                ),
                _DetailRow(
                  label: l10n.currencyDetailLabel,
                  value: transaction.currency,
                ),
                if (transaction.merchant != null)
                  _DetailRow(
                    label: l10n.merchantDetailLabel,
                    value: transaction.merchant!,
                  ),
                if (transaction.description != null)
                  _DetailRow(
                    label: l10n.descriptionDetailLabel,
                    value: transaction.description!,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (transaction.account != null)
              _DetailCard(
                title: l10n.accountDetailLabel,
                children: [
                  _DetailRow(
                    label: l10n.nameDetailLabel,
                    value: transaction.account!.name,
                  ),
                ],
              ),
            if (transaction.fromAccount != null || transaction.toAccount != null)
              _DetailCard(
                title: l10n.transferDetailLabel,
                children: [
                  if (transaction.fromAccount != null)
                    _DetailRow(
                      label: l10n.fromLabel,
                      value: transaction.fromAccount!.name,
                    ),
                  if (transaction.toAccount != null)
                    _DetailRow(
                      label: l10n.toLabel,
                      value: transaction.toAccount!.name,
                    ),
                ],
              ),
            if (transaction.category != null) ...[
              const SizedBox(height: 12),
              _DetailCard(
                title: l10n.categoryLabel,
                children: [
                  _DetailRow(
                    label: l10n.nameDetailLabel,
                    value: transaction.category!.name,
                  ),
                ],
              ),
            ],
            if (transaction.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              _TagsCard(tags: transaction.tags),
            ],
            const SizedBox(height: 12),
            _DetailCard(
              children: [
                _DetailRow(
                  label: l10n.registeredLabel,
                  value: DateFormat('dd/MM/yyyy HH:mm', locale)
                      .format(transaction.createdAt),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEdit(BuildContext context) async {
    final txBloc = context.read<TransactionBloc>();
    final accountBloc = context.read<AccountBloc>();
    final categoryBloc = context.read<CategoryBloc>();
    final tagBloc = context.read<TagBloc>();
    final navigator = Navigator.of(context);

    // Fetch fresh data so fields like amountLocal are always current.
    TransactionModel fresh = transaction;
    try {
      fresh = await TransactionApiService().getTransaction(transaction.id);
    } catch (_) {
      // Fall back to the list copy if the fetch fails.
    }

    if (!context.mounted) return;
    final result = await navigator.push<bool>(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: txBloc),
            BlocProvider.value(value: accountBloc),
            BlocProvider.value(value: categoryBloc),
            BlocProvider.value(value: tagBloc),
          ],
          child: TransactionFormScreen(initialTransaction: fresh),
        ),
      ),
    );
    if (result == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteTransaction),
        content: Text(l10n.deleteTransactionConfirm),
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
    if (confirmed == true && context.mounted) {
      context
          .read<TransactionBloc>()
          .add(DeleteTransaction(transaction.id));
    }
  }
}

class _TagsCard extends StatelessWidget {
  const _TagsCard({required this.tags});

  final List<TagModel> tags;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.tagsTitle,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags
                  .map((tag) => TagChip(tag: tag))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountHero extends StatelessWidget {
  const _AmountHero({required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final Color amountColor;
    final String prefix;

    switch (transaction.type) {
      case TransactionType.expense:
        amountColor = colorScheme.error;
        prefix = '-';
      case TransactionType.income:
        amountColor = const Color(0xFF16A34A);
        prefix = '+';
      case TransactionType.transfer:
        amountColor = const Color(0xFF2563EB);
        prefix = '';
    }

    return Column(
      children: [
        Text(
          '$prefix${CurrencyFormatter.format(transaction.amount, transaction.currency)}',
          style: textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: amountColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
