import 'package:flutter/material.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../../accounts/models/account_model.dart';

/// Shows a modal bottom sheet listing [accounts] for the user to pick one.
///
/// Resolves with the selected [AccountModel], or `null` if dismissed
/// without a selection.
Future<AccountModel?> showAccountPickerSheet(
  BuildContext context, {
  required List<AccountModel> accounts,
}) {
  return showModalBottomSheet<AccountModel>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _AccountPickerSheet(accounts: accounts),
  );
}

class _AccountPickerSheet extends StatelessWidget {
  const _AccountPickerSheet({required this.accounts});

  final List<AccountModel> accounts;

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
              AppLocalizations.of(context)!.selectAccount,
              style: textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (accounts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                AppLocalizations.of(context)!.noAccountsAvailable,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: accounts.length,
                itemBuilder: (_, i) {
                  final account = accounts[i];
                  return ListTile(
                    leading: Icon(account.type.icon,
                        color: colorScheme.primary),
                    title: Text(account.name),
                    subtitle: Text(
                      '${account.currency}  '
                      '${account.bank ?? account.type.label}',
                    ),
                    trailing: Text(
                      _formatBalance(account),
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () => Navigator.of(context).pop(account),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _formatBalance(AccountModel account) {
    final sign = account.currentBalance < 0 ? '' : '';
    return '$sign${account.currency} ${account.currentBalance.abs().toStringAsFixed(2)}';
  }
}
