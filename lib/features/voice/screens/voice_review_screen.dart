import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../../accounts/models/account_model.dart';
import '../../categories/models/category_model.dart';
import '../../transactions/models/tag_model.dart';
import '../bloc/voice_bloc.dart';
import '../bloc/voice_event.dart';
import '../bloc/voice_state.dart';
import '../models/transaction_draft_model.dart';
import '../widgets/draft_card_widget.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../../shared/utils/localized_message_resolver.dart';

/// Review screen displayed after the backend NLP extracts transaction drafts.
///
/// The user can:
///   - Toggle individual drafts in/out of the confirmation batch.
///   - Tap a draft to edit its fields in a bottom sheet.
///   - Tap "Confirmar todo" to persist all included drafts.
///
/// A [VoiceBloc] in [VoiceStatus.reviewing] must be provided above this widget.
class VoiceReviewScreen extends StatelessWidget {
  const VoiceReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<VoiceBloc, VoiceState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == VoiceStatus.success) {
          final count = state.savedCount;
          AppSnackBar.showSuccess(
            context,
            count == 1
                ? '1 transaccion guardada'
                : '$count transacciones guardadas',
          );
          // Pop back to the transactions list; reset bloc for next use.
          Navigator.of(context)
            ..pop() // review
            ..pop(); // record
          context.read<VoiceBloc>().add(const VoiceReset());
        }

        if (state.status == VoiceStatus.error && state.errorMessage != null) {
          AppSnackBar.showError(
            context,
            state.errorMessage!.resolve(AppLocalizations.of(context)!),
            actionLabel: state.savedCount > 0 ? null : 'Reintentar',
            onAction: state.savedCount > 0
                ? null
                : () => context.read<VoiceBloc>().add(
                      const VoiceDraftConfirmed(),
                    ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Revisar transacciones'),
        ),
        body: const _ReviewBody(),
        floatingActionButton: const _ConfirmFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class _ReviewBody extends StatelessWidget {
  const _ReviewBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VoiceBloc, VoiceState>(
      builder: (context, state) {
        if (state.status == VoiceStatus.saving) {
          return const Center(child: CircularProgressIndicator());
        }

        final drafts = state.drafts;

        if (drafts.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 56,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No se encontraron transacciones',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Volver a grabar'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 12, bottom: 100),
          itemCount: drafts.length,
          itemBuilder: (context, index) {
            final draft = drafts[index];
            return DraftCardWidget(
              draft: draft,
              index: index,
              onEdit: () => _openEditSheet(context, index, draft, state),
              availableAccounts: state.availableAccounts,
              availableCategories: state.availableCategories,
              onToggleIncluded: (value) {
                context.read<VoiceBloc>().add(
                      VoiceDraftUpdated(
                        index: index,
                        draft: draft.copyWith(included: value),
                      ),
                    );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _openEditSheet(
    BuildContext context,
    int index,
    TransactionDraftModel draft,
    VoiceState state,
  ) async {
    final bloc = context.read<VoiceBloc>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: _DraftEditSheet(
          index: index,
          draft: draft,
          availableAccounts: state.availableAccounts,
          availableCategories: state.availableCategories,
          availableTags: state.availableTags,
        ),
      ),
    );
  }
}

class _ConfirmFab extends StatelessWidget {
  const _ConfirmFab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VoiceBloc, VoiceState>(
      builder: (context, state) {
        final includedDrafts = state.drafts.where((d) => d.included).toList();
        final includedCount = includedDrafts.length;
        final isBusy = state.status == VoiceStatus.saving;
        final allValid = includedDrafts.every(
          (d) => d.accountId != null && d.categoryId != null,
        );
        final canConfirm = includedCount > 0 && !isBusy && allValid;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: FloatingActionButton.extended(
              onPressed: canConfirm
                  ? () => context
                      .read<VoiceBloc>()
                      .add(const VoiceDraftConfirmed())
                  : null,
              backgroundColor: canConfirm
                  ? const Color(0xFF1D9E75)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              foregroundColor: canConfirm
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              label: isBusy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      !allValid && includedCount > 0
                          ? 'Completa los campos requeridos'
                          : includedCount == 1
                              ? 'Confirmar 1 transaccion'
                              : 'Confirmar $includedCount transacciones',
                    ),
              icon: isBusy ? null : const Icon(Icons.check_rounded),
            ),
          ),
        );
      },
    );
  }
}

class _DraftEditSheet extends StatefulWidget {
  const _DraftEditSheet({
    required this.index,
    required this.draft,
    required this.availableAccounts,
    required this.availableCategories,
    required this.availableTags,
  });

  final int index;
  final TransactionDraftModel draft;
  final List<AccountModel> availableAccounts;
  final List<CategoryModel> availableCategories;
  final List<TagModel> availableTags;

  @override
  State<_DraftEditSheet> createState() => _DraftEditSheetState();
}

class _DraftEditSheetState extends State<_DraftEditSheet> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _merchantCtrl;
  late final TextEditingController _descriptionCtrl;
  late String _selectedCurrency;
  late DateTime _selectedDate;
  String? _selectedCategoryId;
  String? _selectedAccountId;
  late List<TagModel> _selectedTags;

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    final d = widget.draft;
    _amountCtrl =
        TextEditingController(text: d.amount.toStringAsFixed(2));
    _merchantCtrl = TextEditingController(text: d.merchant ?? '');
    _descriptionCtrl = TextEditingController(text: d.description ?? '');
    _selectedCurrency = d.currency;
    _selectedDate = d.transactionDate;
    _selectedCategoryId = d.categoryId;
    _selectedAccountId = d.accountId;
    _selectedTags = List.of(d.tags);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _merchantCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) return;

    final selectedCategory = widget.availableCategories
        .where((c) => c.id == _selectedCategoryId)
        .firstOrNull;
    final selectedAccount = widget.availableAccounts
        .where((a) => a.id == _selectedAccountId)
        .firstOrNull;

    final updated = widget.draft.copyWith(
      amount: amount,
      currency: _selectedCurrency,
      merchant: _merchantCtrl.text.trim().isEmpty
          ? null
          : _merchantCtrl.text.trim(),
      clearMerchant: _merchantCtrl.text.trim().isEmpty,
      description: _descriptionCtrl.text.trim().isEmpty
          ? null
          : _descriptionCtrl.text.trim(),
      clearDescription: _descriptionCtrl.text.trim().isEmpty,
      transactionDate: _selectedDate,
      categoryId: selectedCategory?.id,
      categoryName: selectedCategory?.name,
      clearCategoryId: selectedCategory == null,
      clearCategoryName: selectedCategory == null,
      accountId: selectedAccount?.id,
      accountName: selectedAccount?.name,
      clearAccountId: selectedAccount == null,
      clearAccountName: selectedAccount == null,
      tags: _selectedTags,
    );

    context
        .read<VoiceBloc>()
        .add(VoiceDraftUpdated(index: widget.index, draft: updated));
    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Editar transaccion',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Monto'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCurrency,
                  decoration:
                      const InputDecoration(labelText: 'Moneda'),
                  items: const [
                    DropdownMenuItem(value: 'PEN', child: Text('S/ PEN')),
                    DropdownMenuItem(value: 'USD', child: Text('\$ USD')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedCurrency = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _merchantCtrl,
            decoration:
                const InputDecoration(labelText: 'Comercio (opcional)'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _descriptionCtrl,
            decoration:
                const InputDecoration(labelText: 'Descripcion (opcional)'),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _selectedCategoryId,
            decoration: const InputDecoration(labelText: 'Categoria'),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('Sin categoria'),
              ),
              ...widget.availableCategories.map(
                (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
              ),
            ],
            onChanged: (v) => setState(() => _selectedCategoryId = v),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _selectedAccountId,
            decoration: const InputDecoration(labelText: 'Cuenta'),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('Sin cuenta'),
              ),
              ...widget.availableAccounts.map(
                (a) => DropdownMenuItem(value: a.id, child: Text(a.name)),
              ),
            ],
            onChanged: (v) => setState(() => _selectedAccountId = v),
          ),
          const SizedBox(height: 16),

          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Fecha',
                suffixIcon: Icon(Icons.calendar_today_outlined, size: 20),
              ),
              child: Text(_dateFormat.format(_selectedDate)),
            ),
          ),
          const SizedBox(height: 16),

          if (widget.availableTags.isNotEmpty) ...[
            Text(
              'Etiquetas',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.availableTags.map((tag) {
                final isSelected =
                    _selectedTags.any((t) => t.id == tag.id);
                final tagColor = tag.color != null
                    ? Color(int.parse(
                        '0xFF${tag.color!.replaceAll('#', '')}'))
                    : theme.colorScheme.primary;
                return GestureDetector(
                  onTap: () => setState(() {
                    if (isSelected) {
                      _selectedTags.removeWhere((t) => t.id == tag.id);
                    } else {
                      _selectedTags.add(tag);
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? tagColor.withValues(alpha: 0.15)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: isSelected
                            ? tagColor
                            : theme.colorScheme.outline.withValues(alpha: 0.3),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      tag.name,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? tagColor
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: const Color(0xFF1D9E75),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Guardar cambios'),
            ),
          ),
        ],
      ),
    );
  }
}
