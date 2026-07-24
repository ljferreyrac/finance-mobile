import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../../accounts/bloc/account_bloc.dart';
import '../../accounts/bloc/account_event.dart';
import '../../accounts/bloc/account_state.dart';
import '../../accounts/models/account_model.dart';
import '../../categories/bloc/category_bloc.dart';
import '../../categories/bloc/category_event.dart';
import '../../categories/bloc/category_state.dart';
import '../../categories/models/category_model.dart';
import '../bloc/tag_bloc.dart';
import '../bloc/tag_event.dart';
import '../bloc/tag_state.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../data/exchange_rate_repository.dart';
import '../models/exchange_rate_model.dart';
import '../models/tag_model.dart';
import '../models/transaction_model.dart';
import '../widgets/tag_chip.dart';
import '../widgets/tag_picker_sheet.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../widgets/transaction_type_selector.dart';

/// Adaptive form for creating or editing a transaction.
///
/// The visible fields change depending on the selected [TransactionType]:
/// - EXPENSE: account + category (required) + merchant
/// - INCOME: account + category (optional) + merchant/source
/// - TRANSFER: fromAccount + toAccount (no category)
///
/// [TransactionBloc], [AccountBloc], and [CategoryBloc] must all be
/// provided above this route.
class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key, this.initialTransaction});

  final TransactionModel? initialTransaction;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _merchantController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountLocalController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String _currency = 'PEN';
  DateTime _date = DateTime.now();
  AccountModel? _selectedAccount;
  AccountModel? _selectedFromAccount;
  AccountModel? _selectedToAccount;
  CategoryModel? _selectedCategory;
  List<TagModel> _selectedTags = [];

  /// True when the selected account currency differs from [_currency].
  bool _showAmountLocal = false;

  final _receivedAmountController = TextEditingController();

  /// When true, the next CategoryActionSuccess auto-selects the last category.
  bool _pendingCategoryAutoSelect = false;

  /// Today's exchange rate, loaded lazily the first time it is needed.
  ExchangeRateModel? _exchangeRate;

  /// Prevents auto-prefill from overwriting a value the user has already typed.
  bool _amountLocalUserEdited = false;

  /// Guards against overwriting a selection the user already made; flips
  /// true the first time defaults are applied.
  bool _defaultsApplied = false;

  bool get _isEditing => widget.initialTransaction != null;

  @override
  void initState() {
    super.initState();

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

    final tx = widget.initialTransaction;
    if (tx != null) {
      _type = tx.type;
      _amountController.text = tx.amount.toStringAsFixed(2);
      _currency = tx.currency;
      _date = tx.transactionDate;
      _merchantController.text = tx.merchant ?? '';
      _descriptionController.text = tx.description ?? '';
      _selectedTags = List.of(tx.tags);
      if (tx.amountLocal != null) {
        if (tx.type == TransactionType.transfer) {
          // For transfers, amountLocal holds the received amount in the
          // destination currency, not a same-transaction conversion.
          _receivedAmountController.text = tx.amountLocal!.toStringAsFixed(2);
        } else {
          _amountLocalController.text = tx.amountLocal!.toStringAsFixed(2);
          _amountLocalUserEdited = true;
        }
      }
    }

    // Track user edits so later rebuilds do not overwrite typed values.
    _amountLocalController.addListener(() {
      if (!_amountLocalUserEdited && _amountLocalController.text.isNotEmpty) {
        _amountLocalUserEdited = true;
      }
    });

    // Apply selections now in case the BLoCs are already loaded, so the
    // form is not empty on the first frame.
    _applyAccountDefaults(context.read<AccountBloc>().state);
    _applyCategoryDefaults(context.read<CategoryBloc>().state);
  }

  /// In create mode, picks the default account once [_selectedAccount] and
  /// [_defaultsApplied] are still unset. In edit mode, matches the
  /// transaction's account/fromAccount/toAccount by id once accounts load.
  void _applyAccountDefaults(AccountState state) {
    final List<AccountModel> accounts;
    if (state is AccountLoaded) {
      accounts = state.accounts;
    } else if (state is AccountOperationSuccess) {
      accounts = state.accounts;
    } else {
      return;
    }

    final tx = widget.initialTransaction;
    if (tx != null) {
      if (tx.account != null && _selectedAccount == null) {
        _selectedAccount =
            accounts.where((a) => a.id == tx.account!.id).firstOrNull;
      }
      if (tx.fromAccount != null && _selectedFromAccount == null) {
        _selectedFromAccount =
            accounts.where((a) => a.id == tx.fromAccount!.id).firstOrNull;
      }
      if (tx.toAccount != null && _selectedToAccount == null) {
        _selectedToAccount =
            accounts.where((a) => a.id == tx.toAccount!.id).firstOrNull;
      }
    } else if (!_defaultsApplied && _selectedAccount == null) {
      _selectedAccount = accounts.where((a) => a.isDefault).firstOrNull;
    }
  }

  /// In create mode, picks the default category once [_selectedCategory] and
  /// [_defaultsApplied] are still unset. In edit mode, matches the
  /// transaction's category by id once categories load.
  void _applyCategoryDefaults(CategoryState state) {
    final List<CategoryModel> categories;
    if (state is CategoryLoaded) {
      categories = state.categories;
    } else if (state is CategoryActionSuccess) {
      categories = state.categories;
    } else {
      return;
    }

    final tx = widget.initialTransaction;
    if (tx != null) {
      if (tx.category != null && _selectedCategory == null) {
        _selectedCategory =
            categories.where((c) => c.id == tx.category!.id).firstOrNull;
      }
    } else if (!_defaultsApplied && _selectedCategory == null) {
      _selectedCategory =
          categories.where((c) => c.isDefault).firstOrNull;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _descriptionController.dispose();
    _amountLocalController.dispose();
    _receivedAmountController.dispose();
    super.dispose();
  }

  /// Effective account currency for the current type; null if no account
  /// has been selected yet.
  String? get _accountCurrency {
    if (_type == TransactionType.transfer) return null;
    return _selectedAccount?.currency;
  }

  /// Recomputes [_showAmountLocal] whenever the account or transaction
  /// currency changes, then lazily fetches the exchange rate to prefill it.
  void _updateCrossCurrencyState() {
    final accountCcy = _accountCurrency;
    final shouldShow = accountCcy != null && accountCcy != _currency;

    if (!shouldShow) {
      setState(() {
        _showAmountLocal = false;
        if (!_amountLocalUserEdited) _amountLocalController.clear();
      });
      return;
    }

    setState(() => _showAmountLocal = true);
    _loadExchangeRateAndPrefill();
  }

  /// Fetches today's rate (once) and prefills [_amountLocalController] with
  /// `amount * sellRate`, unless the user already edited the field.
  Future<void> _loadExchangeRateAndPrefill() async {
    if (_amountLocalUserEdited) return;

    ExchangeRateModel? rate = _exchangeRate;
    if (rate == null) {
      try {
        rate = await ExchangeRateRepositoryImpl().getToday();
        if (mounted) setState(() => _exchangeRate = rate);
      } catch (_) {
        // Non-fatal: field stays empty, user enters the value manually.
        return;
      }
    }

    if (!mounted || _amountLocalUserEdited) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount != null && amount > 0) {
      final local = amount * rate.sellRate;
      setState(() {
        _amountLocalController.text = local.toStringAsFixed(2);
      });
    }
  }

  void _onTypeChanged(TransactionType type) {
    setState(() {
      _type = type;
      // Transfer currency is set when picking the from-account (below); for
      // other types the currency the user already chose is left untouched.
      if (type != TransactionType.transfer) {
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: Localizations.localeOf(context),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickAccount({
    required List<AccountModel> accounts,
    required void Function(AccountModel) onSelected,
  }) async {
    final picked = await showModalBottomSheet<AccountModel>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AccountPickerSheet(accounts: accounts),
    );
    if (picked != null) onSelected(picked);
  }

  Future<void> _openNewCategoryDialog() async {
    final nameCtrl = TextEditingController();
    String? selectedColor;

    const presetColors = [
      '#4CAF50', '#2196F3', '#FF5733',
      '#FF9800', '#9C27B0', '#607D8B',
    ];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nueva categoria'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 16),
              const Text('Color', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: presetColors.map((hex) {
                  final color = Color(
                      int.parse('0xFF${hex.replaceAll('#', '')}'));
                  final isChosen =
                      selectedColor?.toLowerCase() == hex.toLowerCase();
                  return GestureDetector(
                    onTap: () => setDialogState(
                        () => selectedColor = isChosen ? null : hex),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isChosen
                            ? Border.all(
                                color: Colors.black87, width: 2.5)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: isChosen
                          ? const Icon(Icons.check,
                              size: 16, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );

    final name = nameCtrl.text.trim();
    nameCtrl.dispose();

    if (confirmed == true && mounted) {
      if (name.isEmpty) return;
      setState(() => _pendingCategoryAutoSelect = true);
      context.read<CategoryBloc>().add(
            CreateCategory(name: name, color: selectedColor),
          );
    }
  }

  Future<void> _pickCategory({
    required List<CategoryModel> categories,
  }) async {
    final picked = await showModalBottomSheet<CategoryModel>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CategoryPickerSheet(
        categories: categories,
        onNewCategory: () {
          Navigator.of(context).pop();
          _openNewCategoryDialog();
        },
      ),
    );
    if (picked != null) {
      setState(() => _selectedCategory = picked);
    }
  }

  void _submit(List<AccountModel> accounts, List<CategoryModel> categories) {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;

    final l10n = AppLocalizations.of(context)!;

    if (_type == TransactionType.transfer) {
      if (_selectedFromAccount == null || _selectedToAccount == null) {
        AppSnackBar.showInfo(context, l10n.selectAccountsFirst);
        return;
      }
      if (_selectedFromAccount!.id == _selectedToAccount!.id) {
        AppSnackBar.showInfo(context, l10n.sameAccountError);
        return;
      }
    } else if (_type == TransactionType.expense) {
      if (_selectedCategory == null) {
        AppSnackBar.showInfo(context, l10n.selectCategoryFirst);
        return;
      }
      if (_selectedAccount == null) {
        AppSnackBar.showInfo(context, l10n.selectAccountFirst);
        return;
      }
    } else {
      if (_selectedAccount == null) {
        AppSnackBar.showInfo(context, l10n.selectAccountFirst);
        return;
      }
    }

    final amountLocal = _showAmountLocal
        ? double.tryParse(_amountLocalController.text.trim())
        : null;

    final body = <String, dynamic>{
      'type': _type.toJson(),
      'amount': amount,
      'currency': _currency,
      if (amountLocal != null) 'amountLocal': amountLocal,
      'transactionDate': _date.toIso8601String().split('T').first,
      if (_merchantController.text.trim().isNotEmpty)
        'merchant': _merchantController.text.trim(),
      if (_descriptionController.text.trim().isNotEmpty)
        'description': _descriptionController.text.trim(),
      'tagIds': _selectedTags.map((t) => t.id).toList(),
    };

    switch (_type) {
      case TransactionType.expense:
      case TransactionType.income:
        body['accountId'] = _selectedAccount!.id;
        if (_selectedCategory != null) {
          body['categoryId'] = _selectedCategory!.id;
        }
      case TransactionType.transfer:
        body['fromAccountId'] = _selectedFromAccount!.id;
        body['toAccountId'] = _selectedToAccount!.id;
        body['currency'] = _selectedFromAccount!.currency;
        final isCrossCurrency = _selectedFromAccount!.currency !=
            _selectedToAccount!.currency;
        if (isCrossCurrency) {
          final received =
              double.tryParse(_receivedAmountController.text.trim());
          if (received != null && received > 0) {
            body['amountLocal'] = received;
          }
        }
    }

    if (_isEditing) {
      context
          .read<TransactionBloc>()
          .add(UpdateTransaction(widget.initialTransaction!.id, body));
    } else {
      context.read<TransactionBloc>().add(CreateTransaction(body));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editTransaction : l10n.newTransaction),
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionOperationSuccess) {
            Navigator.of(context).pop(true);
          }
          if (state is TransactionError) {
            AppSnackBar.showError(context, state.message);
          }
        },
        child: BlocListener<AccountBloc, AccountState>(
          listener: (context, accountState) {
            setState(() {
              _applyAccountDefaults(accountState);
              // In create mode, defaults count as applied once this bloc
              // has responded at least once (see _defaultsApplied).
              if (!_isEditing) _defaultsApplied = true;
            });
            _updateCrossCurrencyState();
          },
          child: BlocListener<CategoryBloc, CategoryState>(
            listener: (context, categoryState) {
              setState(() {
                if (_pendingCategoryAutoSelect &&
                    categoryState is CategoryActionSuccess &&
                    categoryState.categories.isNotEmpty) {
                  _selectedCategory = categoryState.categories.last;
                  _pendingCategoryAutoSelect = false;
                } else {
                  _applyCategoryDefaults(categoryState);
                }
                if (!_isEditing) _defaultsApplied = true;
              });
            },
            child: BlocBuilder<AccountBloc, AccountState>(
              builder: (context, accountState) {
                return BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, categoryState) {
                    final accounts = _extractAccounts(accountState);
                    final categories = _extractCategories(categoryState);
                    final isLoading =
                        context.read<TransactionBloc>().state
                            is TransactionLoading;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TransactionTypeSelector(
                              selected: _type,
                              onChanged: _onTypeChanged,
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _amountController,
                              decoration: InputDecoration(
                                labelText: l10n.amountLabel,
                                hintText: '0.00',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return l10n.amountRequired;
                                }
                                final n = double.tryParse(v.trim());
                                if (n == null || n <= 0) {
                                  return l10n.amountInvalid;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Read-only for transfers once the from-account
                            // is set, since its currency then drives this.
                            _buildCurrencyToggle(),
                            const SizedBox(height: 12),

                            if (_showAmountLocal) ...[
                              _buildAmountLocalField(),
                              const SizedBox(height: 12),
                            ],

                            _DatePickerField(
                              date: _date,
                              onTap: _pickDate,
                            ),
                            const SizedBox(height: 16),

                            if (_type == TransactionType.transfer)
                              _buildTransferFields(accounts)
                            else
                              _buildExpenseIncomeFields(accounts, categories),

                            TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: l10n.descriptionLabel,
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 24),

                            FilledButton(
                              onPressed: isLoading
                                  ? null
                                  : () => _submit(accounts, categories),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(_isEditing
                                      ? l10n.saveChanges
                                      : l10n.saveTransaction),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyToggle() {
    final isReadOnly = _type == TransactionType.transfer &&
        _selectedFromAccount != null;

    if (isReadOnly) {
      return InputDecorator(
        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.currencyLabel),
        child: Text(
          _selectedFromAccount!.currency,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'PEN', label: Text('S/ PEN')),
        ButtonSegment(value: 'USD', label: Text('\$ USD')),
      ],
      selected: {_currency},
      onSelectionChanged: (s) {
        setState(() => _currency = s.first);
        _amountLocalUserEdited = false;
        _updateCrossCurrencyState();
      },
      style: const ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildAmountLocalField() {
    final l10n = AppLocalizations.of(context)!;

    // Label reflects the conversion direction; falls back to a generic
    // label for cross-currency combinations beyond PEN/USD.
    final accountCcy = _accountCurrency;
    final String label;
    if (_currency == 'USD' && accountCcy == 'PEN') {
      label = l10n.amountLocalLabel; // "Equivalente en S/"
    } else if (_currency == 'PEN' && accountCcy == 'USD') {
      label = l10n.amountLocalLabelUsd; // "Equivalente en $"
    } else {
      label = l10n.amountLocalLabel;
    }

    final String? helperText = _exchangeRate != null
        ? l10n.exchangeRateHelper(
            _exchangeRate!.sellRate.toStringAsFixed(2),
          )
        : null;

    return TextFormField(
      controller: _amountLocalController,
      decoration: InputDecoration(
        labelText: label,
        hintText: '0.00',
        helperText: helperText,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      validator: (v) {
        if (!_showAmountLocal) return null;
        if (v == null || v.trim().isEmpty) return l10n.amountRequired;
        final n = double.tryParse(v.trim());
        if (n == null || n <= 0) return l10n.amountInvalid;
        return null;
      },
    );
  }

  Widget _buildExpenseIncomeFields(
    List<AccountModel> accounts,
    List<CategoryModel> categories,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PickerField(
          label: l10n.accountLabel,
          value: _selectedAccount?.name,
          hint: l10n.selectAccount,
          icon: Icons.account_balance_wallet_outlined,
          onTap: () => _pickAccount(
            accounts: accounts,
            onSelected: (a) {
              setState(() => _selectedAccount = a);
              _amountLocalUserEdited = false;
              _updateCrossCurrencyState();
            },
          ),
        ),
        const SizedBox(height: 12),

        _PickerField(
          label: _type == TransactionType.expense
              ? l10n.categoryRequired
              : l10n.categoryOptional,
          value: _selectedCategory?.name,
          hint: l10n.selectCategory,
          icon: Icons.category_outlined,
          onTap: () => _pickCategory(categories: categories),
        ),
        const SizedBox(height: 12),

        _TagsField(
          selected: _selectedTags,
          onTap: () async {
            final result = await showTagPickerSheet(
              context,
              selected: _selectedTags,
              tagBloc: context.read<TagBloc>(),
            );
            setState(() => _selectedTags = result);
          },
        ),
        const SizedBox(height: 12),

        TextFormField(
          controller: _merchantController,
          decoration: InputDecoration(
            labelText: _type == TransactionType.income
                ? l10n.merchantLabelIncome
                : l10n.merchantLabelExpense,
          ),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildTransferFields(List<AccountModel> accounts) {
    final l10n = AppLocalizations.of(context)!;
    final isCrossCurrency = _selectedFromAccount != null &&
        _selectedToAccount != null &&
        _selectedFromAccount!.currency != _selectedToAccount!.currency;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PickerField(
          label: l10n.fromAccountLabel,
          value: _selectedFromAccount?.name,
          hint: l10n.selectFromAccount,
          icon: Icons.arrow_upward,
          onTap: () => _pickAccount(
            accounts: accounts,
            onSelected: (a) => setState(() {
              _selectedFromAccount = a;
              _currency = a.currency;
              _receivedAmountController.clear();
            }),
          ),
        ),
        const SizedBox(height: 12),

        _PickerField(
          label: l10n.toAccountLabel,
          value: _selectedToAccount?.name,
          hint: l10n.selectToAccount,
          icon: Icons.arrow_downward,
          onTap: () => _pickAccount(
            accounts: accounts.where((a) {
              return a.id != _selectedFromAccount?.id;
            }).toList(),
            onSelected: (a) => setState(() {
              _selectedToAccount = a;
              _receivedAmountController.clear();
            }),
          ),
        ),
        const SizedBox(height: 12),

        if (isCrossCurrency) ...[
          TextFormField(
            controller: _receivedAmountController,
            decoration: InputDecoration(
              labelText:
                  'Monto recibido (${_selectedToAccount!.currency})',
              hintText: '0.00',
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d{0,2}')),
            ],
            validator: (v) {
              if (!isCrossCurrency) return null;
              if (v == null || v.trim().isEmpty) {
                return l10n.amountRequired;
              }
              final n = double.tryParse(v.trim());
              if (n == null || n <= 0) return l10n.amountInvalid;
              return null;
            },
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  List<AccountModel> _extractAccounts(AccountState state) {
    if (state is AccountLoaded) return state.accounts;
    if (state is AccountOperationSuccess) return state.accounts;
    return [];
  }

  List<CategoryModel> _extractCategories(CategoryState state) {
    if (state is CategoryLoaded) return state.categories;
    if (state is CategoryActionSuccess) return state.categories;
    return [];
  }
}

/// Tappable field that shows currently selected tags or a placeholder.
///
/// Requires [TagBloc] to be available in the widget tree.
class _TagsField extends StatelessWidget {
  const _TagsField({required this.selected, required this.onTap});

  final List<TagModel> selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.tagsLabel,
          suffixIcon: const Icon(Icons.label_outline),
        ),
        child: selected.isEmpty
            ? Text(
                l10n.selectTags,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              )
            : Wrap(
                spacing: 6,
                runSpacing: 4,
                children: selected
                    .map((tag) => TagChip(tag: tag))
                    .toList(),
              ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatted =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.dateLabel,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(formatted),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.hint,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String? value;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(icon),
        ),
        child: Text(
          value ?? hint,
          style: value == null
              ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                  )
              : Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
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

class _CategoryPickerSheet extends StatelessWidget {
  const _CategoryPickerSheet({
    required this.categories,
    required this.onNewCategory,
  });

  final List<CategoryModel> categories;
  final VoidCallback onNewCategory;

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
              AppLocalizations.of(context)!.selectCategory,
              style: textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (categories.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                AppLocalizations.of(context)!.noCategoriesAvailable,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (_, i) {
                  final category = categories[i];
                  final color = category.color != null
                      ? Color(
                          int.parse(
                            category.color!.replaceAll('#', '0xFF'),
                          ),
                        )
                      : colorScheme.primary;

                  return ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: category.icon != null
                          ? Text(category.icon!,
                              style: const TextStyle(fontSize: 16))
                          : Text(
                              category.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                    title: Text(category.name),
                    onTap: () => Navigator.of(context).pop(category),
                  );
                },
              ),
            ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.add, color: colorScheme.primary),
            title: Text(
              AppLocalizations.of(context)!.newCategory,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: onNewCategory,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
