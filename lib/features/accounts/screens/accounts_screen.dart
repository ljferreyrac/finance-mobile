import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../../../../shared/utils/currency_formatter.dart';
import '../../categories/widgets/category_color_picker.dart';
import '../bloc/account_bloc.dart';
import '../bloc/account_event.dart';
import '../bloc/account_state.dart';
import '../models/account_model.dart';
import 'account_form_screen.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../../shared/utils/localized_message_resolver.dart';

/// [AccountBloc] must be provided above this route.
class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  bool _includeDebt = true;

  @override
  void initState() {
    super.initState();
    context.read<AccountBloc>().add(LoadAccounts(includeDebt: _includeDebt));
  }

  void _toggleDebt() {
    setState(() => _includeDebt = !_includeDebt);
    context.read<AccountBloc>().add(LoadAccounts(includeDebt: _includeDebt));
  }

  Future<void> _openForm({AccountModel? account}) async {
    final accountBloc = context.read<AccountBloc>();
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: accountBloc,
          child: AccountFormScreen(initialAccount: account),
        ),
      ),
    );
    if (result == true) {
      // BLoC already refreshed the list after the action.
    }
  }

  Future<void> _onDelete(AccountModel account) async {
    final l10n = AppLocalizations.of(context)!;
    if (account.transactionCount > 0) {
      AppSnackBar.showInfo(
        context,
        l10n.accountInUse(account.name, account.transactionCount),
      );
      return;
    }
    final confirmed = await _showConfirmDeleteDialog(account);
    if (confirmed != true) return;
    if (!mounted) return;
    context.read<AccountBloc>().add(DeleteAccount(account.id));
  }

  Future<bool?> _showConfirmDeleteDialog(AccountModel account) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.deleteAccountConfirm(account.name)),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountsTitle),
        actions: [
          IconButton(
            tooltip: _includeDebt
                ? l10n.netWorthIncludeDebtTooltip
                : l10n.netWorthAssetsOnlyTooltip,
            icon: Icon(
              _includeDebt
                  ? Icons.account_balance_wallet
                  : Icons.account_balance_wallet_outlined,
            ),
            onPressed: _toggleDebt,
          ),
        ],
      ),
      body: BlocConsumer<AccountBloc, AccountState>(
        listener: (context, state) {
          if (state is AccountOperationSuccess) {
            AppSnackBar.showSuccess(context, state.message.resolve(l10n));
          }
          if (state is AccountError) {
            AppSnackBar.showError(
              context,
              state.message.resolve(l10n),
              actionLabel: l10n.retry,
              onAction: () =>
                  context.read<AccountBloc>().add(const LoadAccounts()),
            );
          }
        },
        builder: (context, state) {
          if (state is AccountLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<AccountModel> accounts;
          NetWorthModel? netWorth;

          if (state is AccountLoaded) {
            accounts = state.accounts;
            netWorth = state.netWorth;
          } else if (state is AccountOperationSuccess) {
            accounts = state.accounts;
            netWorth = state.netWorth;
          } else if (state is AccountError) {
            return _ErrorBody(
              message: state.message.resolve(l10n),
              onRetry: () =>
                  context.read<AccountBloc>().add(const LoadAccounts()),
            );
          } else {
            return const SizedBox.shrink();
          }

          return _LoadedBody(
            accounts: accounts,
            netWorth: netWorth,
            includeDebt: _includeDebt,
            onEdit: _openForm,
            onDelete: _onDelete,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        tooltip: l10n.newAccount,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({
    required this.accounts,
    required this.netWorth,
    required this.includeDebt,
    required this.onEdit,
    required this.onDelete,
  });

  final List<AccountModel> accounts;
  final NetWorthModel netWorth;
  final bool includeDebt;
  final void Function({AccountModel? account}) onEdit;
  final Future<void> Function(AccountModel account) onDelete;

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return const _EmptyBody();
    }

    // Separate linked wallets from standalone accounts.
    final linkedWallets = <String, List<AccountModel>>{};
    for (final a in accounts) {
      if (a.linkedAccountId != null) {
        linkedWallets.putIfAbsent(a.linkedAccountId!, () => []).add(a);
      }
    }
    final linkedIds = {
      for (final list in linkedWallets.values)
        for (final a in list) a.id,
    };
    final standalone = accounts.where((a) => !linkedIds.contains(a.id)).toList();

    final items = <Widget>[];
    for (final account in standalone) {
      items.add(_dismissible(context, account));
      final children = linkedWallets[account.id] ?? [];
      for (final wallet in children) {
        items.add(_LinkedWalletRow(
          wallet: wallet,
          onTap: () => onEdit(account: wallet),
          onDelete: () => onDelete(wallet),
        ));
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        _NetWorthHeader(netWorth: netWorth, includeDebt: includeDebt),
        const SizedBox(height: 8),
        ...items,
      ],
    );
  }

  Widget _dismissible(BuildContext context, AccountModel account) {
    return Dismissible(
      key: ValueKey(account.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: Theme.of(context).colorScheme.errorContainer,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      confirmDismiss: (_) async {
        await onDelete(account);
        return false;
      },
      child: _AccountCard(
        account: account,
        onTap: () => onEdit(account: account),
      ),
    );
  }
}

class _LinkedWalletRow extends StatelessWidget {
  const _LinkedWalletRow({
    required this.wallet,
    required this.onTap,
    required this.onDelete,
  });

  final AccountModel wallet;
  final VoidCallback onTap;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accentColor = wallet.color != null
        ? hexToColor(wallet.color!)
        : colorScheme.outline;

    return Dismissible(
      key: ValueKey('linked_${wallet.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: colorScheme.errorContainer,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Icon(Icons.delete_outline, color: colorScheme.onErrorContainer),
      ),
      confirmDismiss: (_) async {
        await onDelete();
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 32, right: 16, bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 20,
              child: Column(
                children: [
                  Container(
                    width: 1.5,
                    height: 16,
                    color: colorScheme.outlineVariant,
                  ),
                  Container(
                    width: 12,
                    height: 1.5,
                    color: colorScheme.outlineVariant,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 52,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(wallet.type.icon, size: 16, color: accentColor),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              wallet.name,
                              style: textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              wallet.bank ?? wallet.type.localizedLabel(context),
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          l10n.balanceInAccount,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NetWorthHeader extends StatelessWidget {
  const _NetWorthHeader({required this.netWorth, required this.includeDebt});

  final NetWorthModel netWorth;
  final bool includeDebt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const primaryColor = Color(0xFF1D9E75);
    final textTheme = Theme.of(context).textTheme;

    final hasPen = netWorth.totalPEN != 0;
    final hasUsd = netWorth.totalUSD != 0;

    // PEN is primary whenever it has a balance (or both are zero); USD only
    // becomes primary when it is the sole non-zero currency.
    final String primaryAmount;
    final String? secondaryAmount;

    if (hasPen || !hasUsd) {
      primaryAmount = CurrencyFormatter.format(netWorth.totalPEN, 'PEN');
      secondaryAmount =
          hasUsd ? CurrencyFormatter.format(netWorth.totalUSD, 'USD') : null;
    } else {
      primaryAmount = CurrencyFormatter.format(netWorth.totalUSD, 'USD');
      secondaryAmount = null;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryColor, Color(0xFF14755A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        children: [
          Text(
            includeDebt ? l10n.netWorthTitle : l10n.netWorthAssetsOnlyTitle,
            style: textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            primaryAmount,
            style: textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          if (secondaryAmount != null) ...[
            const SizedBox(height: 4),
            Text(
              secondaryAmount,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.75),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account, required this.onTap});

  final AccountModel account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final accentColor = account.color != null
        ? hexToColor(account.color!)
        : const Color(0xFF1D9E75);

    final isNegative = account.currentBalance < 0;
    final balanceColor =
        isNegative ? colorScheme.error : colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 72,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                account.type.icon,
                size: 20,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    account.name,
                    style: textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (account.bank != null) ...[
                        Text(
                          account.bank!,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurfaceVariant,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          account.type.localizedLabel(context),
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    CurrencyFormatter.format(
                      account.currentBalance,
                      account.currency,
                    ),
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: balanceColor,
                    ),
                  ),
                  if (account.isDefault)
                    Text(
                      l10n.defaultLabel,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.emptyAccounts,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
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
    final l10n = AppLocalizations.of(context)!;
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
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
