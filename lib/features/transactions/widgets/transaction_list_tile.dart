import 'package:flutter/material.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../shared/utils/currency_formatter.dart';
import '../../categories/widgets/category_color_picker.dart';
import '../models/transaction_model.dart';
import 'tag_chip.dart';

/// A single row in the transaction list.
///
/// - EXPENSE: red minus amount, category icon
/// - INCOME: green plus amount, money icon
/// - TRANSFER: blue neutral amount, swap icon
class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  final TransactionModel transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (leadingColor, amountColor, amountPrefix, leadingIcon) =
        _typeStyle(colorScheme);

    final title = _buildTitle(context);
    final subtitle = _buildSubtitle(context);
    final amountText =
        '$amountPrefix${CurrencyFormatter.format(transaction.amount, transaction.currency)}';

    final tags = transaction.tags;
    // Show at most 2 tags inline; excess shown as "+N" chip.
    final visibleTags = tags.take(2).toList();
    final overflowCount = tags.length - visibleTags.length;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: leadingColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: _buildLeadingContent(leadingColor, leadingIcon),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        ...visibleTags.map((tag) => TagChip(tag: tag)),
                        if (overflowCount > 0)
                          Chip(
                            label: Text(
                              '+$overflowCount',
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                            side: BorderSide(
                              color: colorScheme.outlineVariant,
                              width: 0.5,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                amountText,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  (Color, Color, String, IconData) _typeStyle(ColorScheme cs) {
    switch (transaction.type) {
      case TransactionType.expense:
        return (
          cs.error,
          cs.error,
          '-',
          Icons.label_outline,
        );
      case TransactionType.income:
        return (
          const Color(0xFF16A34A),
          const Color(0xFF16A34A),
          '+',
          Icons.south_east,
        );
      case TransactionType.transfer:
        return (
          const Color(0xFF2563EB),
          const Color(0xFF2563EB),
          '',
          Icons.swap_horiz,
        );
    }
  }

  Widget _buildLeadingContent(Color color, IconData fallbackIcon) {
    if (transaction.category?.icon != null) {
      return Text(
        transaction.category!.icon!,
        style: const TextStyle(fontSize: 20),
      );
    }

    final categoryColor = transaction.category?.color != null
        ? hexToColor(transaction.category!.color!)
        : color;

    return Icon(fallbackIcon, size: 20, color: categoryColor);
  }

  String _buildTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (transaction.type) {
      case TransactionType.expense:
        return transaction.merchant ??
            transaction.category?.name ??
            l10n.transactionTypeExpense;
      case TransactionType.income:
        return transaction.merchant ??
            transaction.category?.name ??
            l10n.transactionTypeIncome;
      case TransactionType.transfer:
        return l10n.transactionTypeTransfer;
    }
  }

  String _buildSubtitle(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final dateStr = DateFormat('d MMM', locale)
        .format(transaction.transactionDate);

    switch (transaction.type) {
      case TransactionType.expense:
      case TransactionType.income:
        final accountName = transaction.account?.name ?? '';
        return '$accountName  $dateStr';
      case TransactionType.transfer:
        final from = transaction.fromAccount?.name ?? '';
        final to = transaction.toAccount?.name ?? '';
        return '$from -> $to  $dateStr';
    }
  }
}
