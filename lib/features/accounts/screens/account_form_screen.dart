import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../../categories/widgets/category_color_picker.dart';
import '../bloc/account_bloc.dart';
import '../bloc/account_event.dart';
import '../bloc/account_state.dart';
import '../models/account_model.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../../shared/utils/localized_message_resolver.dart';

/// Pass [initialAccount] to enter edit mode (fields are pre-filled).
/// [AccountBloc] must be provided above this route.
class AccountFormScreen extends StatefulWidget {
  const AccountFormScreen({super.key, this.initialAccount});

  final AccountModel? initialAccount;

  @override
  State<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends State<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _closingDayController = TextEditingController();
  final _dueDayController = TextEditingController();

  AccountType _type = AccountType.bank;
  String _currency = 'PEN';
  String? _color;
  bool _isDefault = false;
  bool _isActive = true;
  String? _linkedAccountId;

  List<AccountModel> _bankAccounts = [];

  bool get _isEditing => widget.initialAccount != null;

  @override
  void initState() {
    super.initState();
    final currentState = context.read<AccountBloc>().state;
    if (currentState is AccountLoaded) {
      _bankAccounts = currentState.accounts
          .where((a) =>
              a.type == AccountType.bank &&
              a.id != widget.initialAccount?.id)
          .toList();
    }
    context.read<AccountBloc>().add(const LoadAccounts());
    final account = widget.initialAccount;
    if (account != null) {
      _nameController.text = account.name;
      _type = account.type;
      _currency = account.currency;
      _color = account.color;
      _isDefault = account.isDefault;
      _isActive = account.isActive;
      _linkedAccountId = account.linkedAccountId;
      if (account.creditLimit != null) {
        _creditLimitController.text = account.creditLimit!.toStringAsFixed(2);
      }
      if (account.closingDay != null) {
        _closingDayController.text = account.closingDay!.toString();
      }
      if (account.dueDay != null) {
        _dueDayController.text = account.dueDay!.toString();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _creditLimitController.dispose();
    _closingDayController.dispose();
    _dueDayController.dispose();
    super.dispose();
  }

  bool get _showCreditFields => _type == AccountType.creditCard;

  void _onTypeChanged(AccountType type) {
    setState(() {
      _type = type;
      if (type != AccountType.wallet) {
        _linkedAccountId = null;
      }
    });
  }

  Future<void> _pickColor() async {
    final picked =
        await showCategoryColorPicker(context, current: _color);
    if (picked != null) {
      setState(() => _color = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final body = <String, dynamic>{
      'name': _nameController.text.trim(),
      'type': _type.toJson(),
      'currency': _currency,
      if (_color != null) 'color': _color,
      'isDefault': _isDefault,
      if (_isEditing) 'isActive': _isActive,
      if (_linkedAccountId != null) 'linkedAccountId': _linkedAccountId,
    };

    if (!_isEditing) {
      final rawBalance = _balanceController.text.trim();
      body['initialBalance'] =
          rawBalance.isEmpty ? 0.0 : double.tryParse(rawBalance) ?? 0.0;
    }

    if (_showCreditFields) {
      final rawLimit = _creditLimitController.text.trim();
      if (rawLimit.isNotEmpty) {
        body['creditLimit'] = double.tryParse(rawLimit);
      }
      final rawClosing = _closingDayController.text.trim();
      if (rawClosing.isNotEmpty) {
        body['closingDay'] = int.tryParse(rawClosing);
      }
      final rawDue = _dueDayController.text.trim();
      if (rawDue.isNotEmpty) {
        body['dueDay'] = int.tryParse(rawDue);
      }
    }

    if (_isEditing) {
      context
          .read<AccountBloc>()
          .add(UpdateAccount(widget.initialAccount!.id, body));
    } else {
      context.read<AccountBloc>().add(CreateAccount(body));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editAccount : l10n.newAccount),
      ),
      body: BlocListener<AccountBloc, AccountState>(
        listener: (context, state) {
          if (state is AccountOperationSuccess) {
            Navigator.of(context).pop(true);
          }
          if (state is AccountError) {
            AppSnackBar.showError(
                context, state.message.resolve(AppLocalizations.of(context)!));
          }
        },
        child: BlocBuilder<AccountBloc, AccountState>(
          builder: (context, state) {
            final isLoading = state is AccountLoading;
            if (state is AccountLoaded) {
              _bankAccounts = state.accounts
                  .where((a) =>
                      a.type == AccountType.bank &&
                      a.id != widget.initialAccount?.id)
                  .toList();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SectionLabel(label: l10n.accountTypeLabel),
                    const SizedBox(height: 8),
                    _AccountTypeSelector(
                      selected: _type,
                      onChanged: _onTypeChanged,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.accountNameLabel,
                        hintText: l10n.accountNameHint,
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? l10n.accountNameRequired
                              : null,
                    ),
                    const SizedBox(height: 16),

                    if (_type == AccountType.wallet) ...[
                      if (state is AccountLoading && _bankAccounts.isEmpty)
                        const LinearProgressIndicator()
                      else
                        DropdownButtonFormField<String>(
                          key: ValueKey(_bankAccounts.map((a) => a.id).join()),
                          initialValue: _bankAccounts.any(
                                  (a) => a.id == _linkedAccountId)
                              ? _linkedAccountId
                              : null,
                          decoration: InputDecoration(
                            labelText: l10n.linkedBankAccount,
                            helperText: l10n.linkedBankAccountHelper,
                          ),
                          items: [
                            DropdownMenuItem<String>(
                              child: Text(l10n.noLinkedAccount),
                            ),
                            ..._bankAccounts.map(
                              (a) => DropdownMenuItem<String>(
                                value: a.id,
                                child: Text(a.name),
                              ),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _linkedAccountId = v),
                        ),
                      const SizedBox(height: 16),
                    ],

                    _SectionLabel(label: l10n.currencyLabel),
                    const SizedBox(height: 8),
                    _CurrencyToggle(
                      value: _currency,
                      onChanged: (v) => setState(() => _currency = v),
                    ),
                    const SizedBox(height: 16),

                    if (!_isEditing) ...[
                      TextFormField(
                        controller: _balanceController,
                        decoration: InputDecoration(
                          labelText: l10n.initialBalanceLabel,
                          hintText: '0.00',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^-?\d*\.?\d{0,2}')),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    _SectionLabel(label: l10n.colorLabel),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _pickColor,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _color != null
                                  ? hexToColor(_color!)
                                  : const Color(0xFF6B7280),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            child: _color == null
                                ? const Icon(Icons.colorize,
                                    color: Colors.white, size: 20)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: _pickColor,
                          child: Text(
                            _color != null
                                ? l10n.changeColor
                                : l10n.chooseColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_showCreditFields) ...[
                      TextFormField(
                        controller: _creditLimitController,
                        decoration: InputDecoration(
                          labelText: l10n.creditLimitLabel,
                          hintText: '0.00',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _closingDayController,
                              decoration: InputDecoration(
                                labelText: l10n.closingDayLabel,
                                hintText: l10n.dayHint,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) {
                                if (v == null || v.isEmpty) return null;
                                final n = int.tryParse(v);
                                if (n == null || n < 1 || n > 31) {
                                  return l10n.dayInvalid;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _dueDayController,
                              decoration: InputDecoration(
                                labelText: l10n.dueDayLabel,
                                hintText: l10n.dayHint,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) {
                                if (v == null || v.isEmpty) return null;
                                final n = int.tryParse(v);
                                if (n == null || n < 1 || n > 31) {
                                  return l10n.dayInvalid;
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.isDefaultAccount),
                      subtitle: Text(l10n.isDefaultAccountSubtitle),
                      value: _isDefault,
                      onChanged: (v) => setState(() => _isDefault = v),
                    ),

                    if (_isEditing) ...[
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.accountActiveLabel),
                        subtitle: Text(l10n.accountActiveSubtitle),
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
                      ),
                    ],
                    const SizedBox(height: 24),

                    FilledButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_isEditing ? l10n.saveChanges : l10n.createAccount),
                    ),
                  ],
                ),
              ),
            );
          },
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
          ),
    );
  }
}

class _AccountTypeSelector extends StatelessWidget {
  const _AccountTypeSelector({
    required this.selected,
    required this.onChanged,
  });

  final AccountType selected;
  final ValueChanged<AccountType> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const types = AccountType.values;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((type) {
        final isSelected = selected == type;
        return ChoiceChip(
          label: Text(type.localizedLabel(context)),
          avatar: Icon(
            type.icon,
            size: 16,
            color: isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
          selected: isSelected,
          onSelected: (_) => onChanged(type),
        );
      }).toList(),
    );
  }
}

class _CurrencyToggle extends StatelessWidget {
  const _CurrencyToggle({
    required this.value,
    required this.onChanged,
  });

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
      style: const ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
