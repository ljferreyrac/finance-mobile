import 'package:flutter/material.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../models/transaction_model.dart';

/// Segmented control for selecting a transaction type (Gasto/Ingreso/Transfer).
///
/// Each option shows an icon and label, color-coded by type:
/// - EXPENSE: red
/// - INCOME: green
/// - TRANSFER: blue
class TransactionTypeSelector extends StatelessWidget {
  const TransactionTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SegmentedButton<TransactionType>(
      segments: [
        ButtonSegment(
          value: TransactionType.expense,
          label: Text(l10n.transactionTypeExpense),
          icon: const Icon(Icons.arrow_upward, size: 16),
        ),
        ButtonSegment(
          value: TransactionType.income,
          label: Text(l10n.transactionTypeIncome),
          icon: const Icon(Icons.arrow_downward, size: 16),
        ),
        ButtonSegment(
          value: TransactionType.transfer,
          label: Text(l10n.transactionTypeTransferShort),
          icon: const Icon(Icons.swap_horiz, size: 16),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (s) => onChanged(s.first),
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _typeColor(selected, context);
          }
          return Theme.of(context).colorScheme.onSurfaceVariant;
        }),
      ),
    );
  }

  Color _typeColor(TransactionType type, BuildContext context) {
    switch (type) {
      case TransactionType.expense:
        return Theme.of(context).colorScheme.error;
      case TransactionType.income:
        return const Color(0xFF16A34A);
      case TransactionType.transfer:
        return const Color(0xFF2563EB);
    }
  }
}
