import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../data/report_repository.dart';
import '../widgets/report_filter_sheet.dart';
import 'monthly_report_screen.dart';
import 'yearly_report_screen.dart';

/// Top-level reports screen with a Mensual | Anual TabBar.
///
/// Owns a single [ReportBloc] shared by both tabs.
class ReportsShellScreen extends StatefulWidget {
  const ReportsShellScreen({super.key});

  @override
  State<ReportsShellScreen> createState() => _ReportsShellScreenState();
}

class _ReportsShellScreenState extends State<ReportsShellScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ReportBloc _reportBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _reportBloc = ReportBloc(repository: ReportRepositoryImpl())
      ..add(const SwitchToMonthly());

    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _reportBloc.close();
    super.dispose();
  }

  void _onTabChanged() {
    // addListener fires on animation frames too; only act on index changes.
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == 0) {
      _reportBloc.add(const SwitchToMonthly());
    } else {
      _reportBloc.add(const SwitchToYearly());
    }
  }

  Future<void> _openFilterSheet(BuildContext context) async {
    final result = await showReportFilterSheet(
      context,
      currentAccountId: _reportBloc.currentAccountId,
      currentCategoryId: _reportBloc.currentCategoryId,
      currentTagId: _reportBloc.currentTagId,
    );
    if (result != null) {
      _reportBloc.add(ApplyReportFilter(
        accountId: result.accountId,
        categoryId: result.categoryId,
        tagId: result.tagId,
      ));
      // Force the shell to repaint so the AppBar badge reflects the new count.
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filterCount = _reportBloc.activeFilterCount;

    return BlocProvider<ReportBloc>.value(
      value: _reportBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.reportsTitle),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                tooltip: AppLocalizations.of(context)!.filterTooltip,
                icon: Badge(
                  isLabelVisible: filterCount > 0,
                  label: Text('$filterCount'),
                  child: const Icon(Icons.filter_list_outlined),
                ),
                onPressed: () => _openFilterSheet(context),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: colorScheme.primary,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            tabs: [
              Tab(text: AppLocalizations.of(context)!.monthly),
              Tab(text: AppLocalizations.of(context)!.yearly),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            MonthlyReportScreen(),
            YearlyReportScreen(),
          ],
        ),
      ),
    );
  }
}
