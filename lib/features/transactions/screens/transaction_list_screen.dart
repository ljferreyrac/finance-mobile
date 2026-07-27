import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../../shared/utils/localized_message_resolver.dart';

import '../../accounts/bloc/account_bloc.dart';
import '../../accounts/bloc/account_event.dart';
import '../../accounts/bloc/account_state.dart';
import '../../accounts/screens/account_form_screen.dart';
import '../../categories/bloc/category_bloc.dart';
import '../../categories/bloc/category_event.dart';
import '../../categories/bloc/category_state.dart';
import '../../categories/screens/category_form_screen.dart';
import '../bloc/tag_bloc.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction_empty_state.dart';
import '../widgets/transaction_filter_sheet.dart';
import '../widgets/transaction_list_tile.dart';
import 'transaction_detail_screen.dart';
import 'transaction_form_screen.dart';
import '../../voice/voice.dart';

/// Full-page screen listing all transactions with type filtering,
/// infinite scroll, and pull-to-refresh.
///
/// [TransactionBloc] must be provided above this route.
class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final _scrollController = ScrollController();
  TransactionFilter _activeFilter = const TransactionFilter();
  bool _voiceGuardNeedsAccount = false;
  bool _voiceGuardNeedsCategory = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<TransactionBloc>().state;
    if (state is TransactionInitial) {
      context
          .read<TransactionBloc>()
          .add(LoadTransactions(_activeFilter));
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TransactionBloc>().add(const LoadMoreTransactions());
    }
  }

  void _applyTypeFilter(TransactionType? type) {
    final newFilter = type == null
        ? _activeFilter.copyWith(clearType: true)
        : _activeFilter.copyWith(type: type);
    setState(() => _activeFilter = newFilter);
    context.read<TransactionBloc>().add(ApplyFilter(newFilter));
  }

  Future<void> _openFilterSheet() async {
    final result = await showTransactionFilterSheet(
      context,
      current: _activeFilter,
    );
    if (result != null && mounted) {
      setState(() => _activeFilter = result);
      context.read<TransactionBloc>().add(ApplyFilter(result));
    }
  }

  Future<void> _openForm({TransactionModel? transaction}) async {
    final txBloc = context.read<TransactionBloc>();
    final accountBloc = context.read<AccountBloc>();
    final categoryBloc = context.read<CategoryBloc>();
    final tagBloc = context.read<TagBloc>();
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: txBloc),
            BlocProvider.value(value: accountBloc),
            BlocProvider.value(value: categoryBloc),
            BlocProvider.value(value: tagBloc),
          ],
          child: TransactionFormScreen(initialTransaction: transaction),
        ),
      ),
    );
    if (result == true && mounted) {
      context.read<TransactionBloc>().add(const RefreshTransactions());
    }
  }

  void _showVoiceGuardLoadError() {
    AppSnackBar.showError(
      context,
      AppLocalizations.of(context)!.onboardingGenericError,
      actionLabel: AppLocalizations.of(context)!.retry,
      onAction: _checkAndOpenVoice,
    );
  }

  Future<void> _checkAndOpenVoice() async {
    final accountBloc = context.read<AccountBloc>();
    final categoryBloc = context.read<CategoryBloc>();
    accountBloc.add(const LoadAccounts());
    categoryBloc.add(const LoadCategories());

    final List<Object> states;
    try {
      states = await Future.wait([
        accountBloc.stream.firstWhere(
          (s) => s is AccountLoaded || s is AccountError,
        ),
        categoryBloc.stream.firstWhere(
          (s) => s is CategoryLoaded || s is CategoryError,
        ),
      ]);
    } catch (_) {
      if (mounted) _showVoiceGuardLoadError();
      return;
    }

    if (!mounted) return;

    final accountState = states[0];
    final categoryState = states[1];
    if (accountState is AccountError || categoryState is CategoryError) {
      _showVoiceGuardLoadError();
      return;
    }

    final accounts = (accountState as AccountLoaded).accounts;
    final categories = (categoryState as CategoryLoaded).categories;

    if (accounts.isEmpty) {
      setState(() {
        _voiceGuardNeedsAccount = true;
        _voiceGuardNeedsCategory = false;
      });
      return;
    }

    if (categories.isEmpty) {
      setState(() {
        _voiceGuardNeedsCategory = true;
        _voiceGuardNeedsAccount = false;
      });
      return;
    }

    setState(() {
      _voiceGuardNeedsAccount = false;
      _voiceGuardNeedsCategory = false;
    });

    final txBloc = context.read<TransactionBloc>();
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => VoiceBloc(),
          child: const VoiceRecordScreen(),
        ),
      ),
    );
    if (mounted) {
      txBloc.add(const RefreshTransactions());
    }
  }

  Future<void> _openDetail(TransactionModel transaction) async {
    final txBloc = context.read<TransactionBloc>();
    final accountBloc = context.read<AccountBloc>();
    final categoryBloc = context.read<CategoryBloc>();
    final tagBloc = context.read<TagBloc>();
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: txBloc),
            BlocProvider.value(value: accountBloc),
            BlocProvider.value(value: categoryBloc),
            BlocProvider.value(value: tagBloc),
          ],
          child: TransactionDetailScreen(transaction: transaction),
        ),
      ),
    );
    if (mounted) {
      context.read<TransactionBloc>().add(const RefreshTransactions());
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeCount = _activeFilter.activeDimensionCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.transactionsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: AppLocalizations.of(context)!.newTransaction,
            onPressed: () => _openForm(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: badgeCount > 0
                ? Badge(
                    label: Text(
                      '$badgeCount',
                      style: const TextStyle(fontSize: 10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list),
                      tooltip: AppLocalizations.of(context)!.filtersTooltip,
                      onPressed: _openFilterSheet,
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.filter_list),
                    tooltip: AppLocalizations.of(context)!.filtersTooltip,
                    onPressed: _openFilterSheet,
                  ),
          ),
        ],
      ),
      body: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionOperationSuccess) {
            AppSnackBar.showSuccess(
                context, state.message.resolve(AppLocalizations.of(context)!));
            context.read<TransactionBloc>().add(const RefreshTransactions());
          }
          if (state is TransactionError) {
            AppSnackBar.showError(
              context,
              state.message.resolve(AppLocalizations.of(context)!),
              actionLabel: AppLocalizations.of(context)!.retry,
              onAction: () => context
                  .read<TransactionBloc>()
                  .add(LoadTransactions(_activeFilter)),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              if (_voiceGuardNeedsAccount || _voiceGuardNeedsCategory)
                _VoiceGuardBanner(
                  needsAccount: _voiceGuardNeedsAccount,
                  onDismiss: () => setState(() {
                    _voiceGuardNeedsAccount = false;
                    _voiceGuardNeedsCategory = false;
                  }),
                  onAction: () async {
                    if (_voiceGuardNeedsAccount) {
                      await Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) => MultiBlocProvider(
                            providers: [
                              BlocProvider.value(
                                value: context.read<AccountBloc>(),
                              ),
                            ],
                            child: const AccountFormScreen(),
                          ),
                        ),
                      );
                    } else {
                      await Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) => MultiBlocProvider(
                            providers: [
                              BlocProvider.value(
                                value: context.read<CategoryBloc>(),
                              ),
                            ],
                            child: const CategoryFormScreen(),
                          ),
                        ),
                      );
                    }
                    if (mounted) {
                      setState(() {
                        _voiceGuardNeedsAccount = false;
                        _voiceGuardNeedsCategory = false;
                      });
                    }
                  },
                ),
              _TypeFilterBar(
                activeType: _activeFilter.type,
                onSelected: _applyTypeFilter,
              ),
              Expanded(child: _buildBody(state)),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'transaction_list_fab',
            onPressed: () => _openForm(),
            tooltip: AppLocalizations.of(context)!.newTransaction,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'transaction_list_voice_fab',
            onPressed: _checkAndOpenVoice,
            backgroundColor: AppColors.teal400,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.mic_rounded),
            label: Text(AppLocalizations.of(context)!.voiceFabLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(TransactionState state) {
    if (state is TransactionLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<TransactionModel> items;
    bool isLoadingMore;

    if (state is TransactionLoaded) {
      items = state.items;
      isLoadingMore = false;
    } else if (state is TransactionLoadingMore) {
      items = state.items;
      isLoadingMore = true;
    } else if (state is TransactionError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.message.resolve(AppLocalizations.of(context)!),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context
                    .read<TransactionBloc>()
                    .add(LoadTransactions(_activeFilter)),
                child: Text(AppLocalizations.of(context)!.retry),
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }

    if (items.isEmpty) {
      return TransactionEmptyState(filter: _activeFilter);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TransactionBloc>().add(const RefreshTransactions());
      },
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 150),
        itemCount: items.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final transaction = items[index];
          final showDateHeader = index == 0 ||
              !_sameDay(
                items[index - 1].transactionDate,
                transaction.transactionDate,
              );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDateHeader)
                _DateHeader(date: transaction.transactionDate),
              TransactionListTile(
                transaction: transaction,
                onTap: () => _openDetail(transaction),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _TypeFilterBar extends StatelessWidget {
  const _TypeFilterBar({
    required this.activeType,
    required this.onSelected,
  });

  final TransactionType? activeType;
  final void Function(TransactionType? type) onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _Chip(
            label: l10n.filterAll,
            isSelected: activeType == null,
            onTap: () => onSelected(null),
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: l10n.filterExpenses,
            isSelected: activeType == TransactionType.expense,
            onTap: () => onSelected(TransactionType.expense),
            color: AppColors.expense,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: l10n.filterIncome,
            isSelected: activeType == TransactionType.income,
            onTap: () => onSelected(TransactionType.income),
            color: AppColors.income,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: l10n.filterTransfers,
            isSelected: activeType == TransactionType.transfer,
            onTap: () => onSelected(TransactionType.transfer),
            color: AppColors.navy400,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class _VoiceGuardBanner extends StatelessWidget {
  const _VoiceGuardBanner({
    required this.needsAccount,
    required this.onDismiss,
    required this.onAction,
  });

  final bool needsAccount;
  final VoidCallback onDismiss;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final message = needsAccount
        ? l10n.voiceNeedsAccountMessage
        : l10n.voiceNeedsCategoryMessage;
    final actionLabel = needsAccount ? l10n.createAccount : l10n.createCategory;

    return Material(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: colorScheme.onErrorContainer, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
              ),
            ),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onErrorContainer,
                visualDensity: VisualDensity.compact,
              ),
              child: Text(actionLabel),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 18, color: colorScheme.onErrorContainer),
              onPressed: onDismiss,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;

    String label;
    if (isToday) {
      label = l10n.today;
    } else if (isYesterday) {
      label = l10n.yesterday;
    } else {
      label = DateFormat('EEEE, d MMMM', locale).format(date);
      label = label[0].toUpperCase() + label.substring(1);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
