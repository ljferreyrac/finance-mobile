import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../accounts/models/account_model.dart';
import '../../categories/models/category_model.dart';
import '../models/transaction_draft_model.dart';

/// Card displaying a single [TransactionDraftModel] for user review.
///
/// Shows amount, merchant/description, category, account, and date.
/// A warning icon is shown when [TransactionDraftModel.confidence] < 0.7.
/// The card is tappable via [onEdit] and has an include/exclude toggle via
/// [onToggleIncluded].
class DraftCardWidget extends StatelessWidget {
  const DraftCardWidget({
    super.key,
    required this.draft,
    required this.index,
    required this.onEdit,
    required this.onToggleIncluded,
    required this.availableAccounts,
    required this.availableCategories,
  });

  final TransactionDraftModel draft;
  final int index;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggleIncluded;
  final List<AccountModel> availableAccounts;
  final List<CategoryModel> availableCategories;

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = theme.colorScheme;
    final isExpense = draft.type == 'EXPENSE';
    final isIncome = draft.type == 'INCOME';
    final amountColor = isExpense
        ? colorScheme.error
        : isIncome
            ? AppColors.teal400
            : colorScheme.onSurface;
    final amountPrefix = isExpense ? '-' : isIncome ? '+' : '';
    final currencySymbol = draft.currency == 'USD' ? '\$' : 'S/';
    final lowConfidence = draft.confidence < 0.7;

    return Opacity(
      opacity: draft.included ? 1.0 : 0.5,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: draft.included ? onEdit : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: 12),
                  child: Checkbox(
                    value: draft.included,
                    onChanged: (v) => onToggleIncluded(v ?? false),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              draft.merchant ??
                                  draft.description ??
                                  _typeLabel(context, draft.type),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (lowConfidence) ...[
                            const SizedBox(width: 6),
                            Tooltip(
                              message: l10n.voiceLowConfidenceTooltip,
                              child: Icon(
                                Icons.warning_amber_rounded,
                                size: 18,
                                color: colorScheme.tertiary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),

                      _MetaRow(
                        icon: Icons.category_outlined,
                        label: draft.categoryId == null
                            ? l10n.voiceCategoryRequired
                            : (draft.categoryName ?? l10n.voiceNoCategorySelected),
                        isError: draft.categoryId == null,
                      ),
                      const SizedBox(height: 2),
                      _MetaRow(
                        icon: Icons.account_balance_outlined,
                        label: draft.accountId == null
                            ? l10n.voiceAccountRequired
                            : (draft.accountName ?? l10n.voiceNoAccountSelected),
                        isError: draft.accountId == null,
                      ),
                      const SizedBox(height: 2),
                      _MetaRow(
                        icon: Icons.calendar_today_outlined,
                        label: _dateFormat.format(draft.transactionDate),
                      ),
                      if (draft.tags.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 2,
                          children: draft.tags.map((tag) {
                            final chipColor = _parseHexColor(tag.color);
                            return Chip(
                              label: Text(
                                tag.name.isNotEmpty ? tag.name : tag.id,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: chipColor != null
                                      ? _contrastColor(chipColor)
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                              backgroundColor: chipColor?.withValues(alpha: 0.2) ??
                                  colorScheme.surfaceContainerHighest,
                              side: chipColor != null
                                  ? BorderSide(
                                      color: chipColor.withValues(alpha: 0.6),
                                    )
                                  : BorderSide.none,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                Text(
                  '$amountPrefix$currencySymbol ${_formatAmount(draft.amount)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: amountColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatAmount(double value) {
    return value.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  Color? _parseHexColor(String? hex) {
    if (hex == null) return null;
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse(
      cleaned.length == 6 ? 'FF$cleaned' : cleaned,
      radix: 16,
    );
    return value != null ? Color(value) : null;
  }

  Color _contrastColor(Color bg) {
    final luminance = bg.computeLuminance();
    return luminance > 0.4 ? Colors.black87 : Colors.white;
  }

  String _typeLabel(BuildContext context, String type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type.toUpperCase()) {
      case 'INCOME':
        return l10n.transactionTypeIncome;
      case 'TRANSFER':
        return l10n.transactionTypeTransfer;
      default:
        return l10n.transactionTypeExpense;
    }
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    this.isError = false,
  });

  final IconData icon;
  final String label;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final color = isError ? colorScheme.error : colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
