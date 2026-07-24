import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../features/accounts/data/account_repository.dart';
import '../../../features/accounts/models/account_model.dart';
import '../../../shared/models/failure.dart';

/// Step 1 of onboarding: create at least one financial account.
///
/// The "Continue" button is disabled until at least one account has been saved.
/// The last remaining account cannot be deleted.
class StepCreateAccount extends StatefulWidget {
  const StepCreateAccount({super.key, required this.onComplete});

  final Future<void> Function() onComplete;

  @override
  State<StepCreateAccount> createState() => _StepCreateAccountState();
}

class _StepCreateAccountState extends State<StepCreateAccount> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  AccountType _type = AccountType.bank;
  String _currency = 'PEN';
  bool _isLoadingExisting = true;
  bool _isSaving = false;
  bool _isDeleting = false;
  String? _error;
  List<AccountModel> _accounts = [];

  final _repository = AccountRepositoryImpl();

  @override
  void initState() {
    super.initState();
    _loadExistingAccounts();
  }

  Future<void> _loadExistingAccounts() async {
    try {
      final existing = await _repository.getAccounts();
      if (mounted) setState(() => _accounts = existing);
    } catch (_) {
      // Non-fatal: start with empty list if the fetch fails.
    } finally {
      if (mounted) setState(() => _isLoadingExisting = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _addAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      final account = await _repository.createAccount({
        'name': _nameController.text.trim(),
        'type': _type.toJson(),
        'currency': _currency,
        'initialBalance':
            double.tryParse(_balanceController.text.trim()) ?? 0.0,
        'isDefault': _accounts.isEmpty,
      });
      setState(() {
        _accounts = [..._accounts, account];
        _nameController.clear();
        _balanceController.clear();
        _type = AccountType.bank;
        _currency = 'PEN';
      });
    } on Failure catch (f) {
      setState(() => _error = f.message);
    } catch (e) {
      setState(() =>
          _error = AppLocalizations.of(context)!.onboardingGenericError);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteAccount(AccountModel account) async {
    if (_accounts.length <= 1) return;
    setState(() => _isDeleting = true);
    try {
      await _repository.deleteAccount(account.id);
      setState(
          () => _accounts = _accounts.where((a) => a.id != account.id).toList());
    } catch (_) {
      // Ignored: the account stays in the list on failure.
    } finally {
      setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoadingExisting) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.onboardingStep1Title,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 8),
            Text(
              l10n.onboardingStep1Subtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 80.ms),
            const SizedBox(height: 28),

            _SectionLabel(label: l10n.onboardingAccountTypeQuestion),
            const SizedBox(height: 12),
            _AccountTypeGrid(
              selected: _type,
              onChanged: (t) => setState(() => _type = t),
            ).animate().fadeIn(duration: 300.ms, delay: 120.ms),
            const SizedBox(height: 20),

            _SectionLabel(label: l10n.onboardingAccountNameQuestion),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: l10n.onboardingAccountNameHint,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.onboardingAccountNameRequired
                  : null,
            ).animate().fadeIn(duration: 300.ms, delay: 160.ms),
            const SizedBox(height: 20),

            _SectionLabel(label: l10n.currencyLabel),
            const SizedBox(height: 8),
            _CurrencyToggle(
              value: _currency,
              onChanged: (v) => setState(() => _currency = v),
            ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
            const SizedBox(height: 20),

            _SectionLabel(label: l10n.initialBalanceLabel),
            const SizedBox(height: 8),
            TextFormField(
              controller: _balanceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true, signed: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                hintText: '0.00',
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    _currency == 'PEN' ? 'S/' : '\$',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 240.ms),
            const SizedBox(height: 8),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _error!,
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
                ),
              ),

            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _isSaving ? null : _addAccount,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.navy400,
                      ),
                    )
                  : const Icon(Icons.add),
              label: Text(_isSaving
                  ? l10n.onboardingSavingLabel
                  : l10n.onboardingAddAccountButton),
            ).animate().fadeIn(duration: 300.ms, delay: 280.ms),

            if (_accounts.isNotEmpty) ...[
              const SizedBox(height: 24),
              _SectionLabel(label: l10n.onboardingAccountsAddedLabel),
              const SizedBox(height: 8),
              ..._accounts.map((account) => _AccountTile(
                    account: account,
                    canDelete: _accounts.length > 1,
                    isDeleting: _isDeleting,
                    onDelete: () => _deleteAccount(account),
                  ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.05, end: 0)),
            ],

            const SizedBox(height: 32),

            FilledButton(
              onPressed: (_accounts.isNotEmpty && !_isSaving)
                  ? () async {
                      setState(() => _isSaving = true);
                      await widget.onComplete();
                      if (mounted) setState(() => _isSaving = false);
                    }
                  : null,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(l10n.onboardingContinueButton),
            ).animate().fadeIn(duration: 300.ms, delay: 320.ms),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _AccountTypeGrid extends StatelessWidget {
  const _AccountTypeGrid({required this.selected, required this.onChanged});

  final AccountType selected;
  final ValueChanged<AccountType> onChanged;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.1,
      children: AccountType.values.map((type) {
        final isSelected = type == selected;
        return _TypeCard(
          type: type,
          isSelected: isSelected,
          onTap: () => onChanged(type),
        );
      }).toList(),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final AccountType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.teal400 : AppColors.neutral400;
    final bg = isSelected ? AppColors.teal50 : Colors.transparent;
    final border = isSelected ? AppColors.teal400 : AppColors.neutral200;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: isSelected ? 1.5 : 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(type.icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              type.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected ? AppColors.teal400 : AppColors.neutral600,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    height: 1.2,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyToggle extends StatelessWidget {
  const _CurrencyToggle({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'PEN', label: Text('S/ PEN')),
        ButtonSegment(value: 'USD', label: Text('\$ USD')),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
      style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.account,
    required this.canDelete,
    required this.isDeleting,
    required this.onDelete,
  });

  final AccountModel account;
  final bool canDelete;
  final bool isDeleting;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(account.type.icon, color: AppColors.teal400, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '${account.currency == 'PEN' ? 'S/' : '\$'} '
                  '${account.currentBalance.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          if (canDelete)
            IconButton(
              icon: Icon(Icons.close, size: 18, color: cs.onSurfaceVariant),
              onPressed: isDeleting ? null : onDelete,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              tooltip: AppLocalizations.of(context)!.deleteAccount,
            ),
        ],
      ),
    );
  }
}
