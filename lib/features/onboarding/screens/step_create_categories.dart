import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../features/categories/bloc/category_bloc.dart';
import '../../../features/categories/bloc/category_event.dart';
import '../../../features/categories/bloc/category_state.dart';
import '../../../features/categories/widgets/category_color_picker.dart';

enum _Group { expense, income }

class _Preset {
  _Preset({
    required this.name,
    required this.icon,
    required this.color,
    required this.group,
  });

  final String name;
  final String icon;
  final String color;
  final _Group group;
  bool selected = true;
}

class _Custom {
  _Custom({required this.name, required this.icon, required this.color, required this.group});

  final String name;
  final String icon;
  final String color;
  final _Group group;
}

List<_Preset> _buildPresets(AppLocalizations l10n) => [
      _Preset(name: l10n.catFood, icon: '🍕', color: '#16A34A', group: _Group.expense),
      _Preset(name: l10n.catTransport, icon: '🚗', color: '#0891B2', group: _Group.expense),
      _Preset(name: l10n.catHousing, icon: '🏠', color: '#0D9488', group: _Group.expense),
      _Preset(name: l10n.catHealth, icon: '💊', color: '#DC2626', group: _Group.expense),
      _Preset(name: l10n.catEntertainment, icon: '🎬', color: '#7C3AED', group: _Group.expense),
      _Preset(name: l10n.catShopping, icon: '🛒', color: '#D97706', group: _Group.expense),
      _Preset(name: l10n.catEducation, icon: '📚', color: '#65A30D', group: _Group.expense),
      _Preset(name: l10n.catPersonalCare, icon: '✨', color: '#DB2777', group: _Group.expense),
      _Preset(name: l10n.catUtilities, icon: '⚡', color: '#6366F1', group: _Group.expense),
      _Preset(name: l10n.catTravel, icon: '🛫', color: '#2563EB', group: _Group.expense),
      _Preset(name: l10n.catSalary, icon: '💼', color: '#16A34A', group: _Group.income),
      _Preset(name: l10n.catFreelance, icon: '💻', color: '#0891B2', group: _Group.income),
      _Preset(name: l10n.catInvestments, icon: '📈', color: '#7C3AED', group: _Group.income),
      _Preset(name: l10n.catOtherIncome, icon: '➕', color: '#6B7280', group: _Group.income),
    ];

const _kEmojiOptions = [
  '🏠', '🚗', '🍕', '💊', '🎬', '🛒', '📚', '✨', '⚡', '🛫',
  '💼', '💻', '📈', '🎯', '🎮', '🐾', '🌿', '🔧', '🎵', '📱',
  '💰', '🍔', '☕', '🏃', '📦', '🎁', '🌍', '🌴', '🎓', '🧾',
];

/// Step 2 of onboarding: confirm which categories to track.
///
/// All presets are pre-selected. The user can toggle them and add custom ones.
/// The "Finish" button is disabled until at least one category is selected.
///
/// [CategoryBloc] must be provided above this widget.
class StepCreateCategories extends StatefulWidget {
  const StepCreateCategories({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<StepCreateCategories> createState() => _StepCreateCategoriesState();
}

class _StepCreateCategoriesState extends State<StepCreateCategories> {
  List<_Preset>? _presets;
  final List<_Custom> _customs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Build once; preserves toggle state on subsequent dependency changes.
    _presets ??= _buildPresets(AppLocalizations.of(context)!);
  }
  bool _isSaving = false;
  String? _error;

  bool get _hasSelection =>
      (_presets?.any((p) => p.selected) ?? false) || _customs.isNotEmpty;

  /// Dispatches [CreateCategory] and waits for its terminal state, so the
  /// preset/custom loop below stays sequential (matching the previous
  /// awaited-repository-call behaviour) instead of racing concurrent bloc
  /// events.
  Future<bool> _createCategory(
    CategoryBloc bloc, {
    required String name,
    String? icon,
    String? color,
    required bool isDefault,
  }) async {
    bloc.add(CreateCategory(
      name: name,
      icon: icon,
      color: color,
      isDefault: isDefault,
    ));
    final state = await bloc.stream.firstWhere(
      (s) => s is CategoryActionSuccess || s is CategoryError,
    );
    return state is CategoryActionSuccess;
  }

  Future<void> _finish() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });
    final bloc = context.read<CategoryBloc>();
    try {
      int position = 0;
      for (final p in (_presets ?? []).where((p) => p.selected)) {
        final ok = await _createCategory(
          bloc,
          name: p.name,
          icon: p.icon,
          color: p.color,
          isDefault: position == 0,
        );
        if (!ok) throw StateError('createCategory failed for "${p.name}"');
        position++;
      }
      for (final c in _customs) {
        final ok = await _createCategory(
          bloc,
          name: c.name,
          icon: c.icon,
          color: c.color,
          isDefault: false,
        );
        if (!ok) throw StateError('createCategory failed for "${c.name}"');
      }
      widget.onComplete();
    } catch (e) {
      if (mounted) {
        setState(() =>
            _error = AppLocalizations.of(context)!.onboardingCategoriesError);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showCustomForm(_Group group) async {
    final result = await showModalBottomSheet<_Custom>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CustomCategorySheet(group: group),
    );
    if (result != null && mounted) {
      setState(() => _customs.add(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final presets = _presets ?? [];
    final expenses = presets.where((p) => p.group == _Group.expense).toList();
    final income = presets.where((p) => p.group == _Group.income).toList();
    final customExpenses = _customs.where((c) => c.group == _Group.expense).toList();
    final customIncome = _customs.where((c) => c.group == _Group.income).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.onboardingStep2Title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingStep2Subtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 60.ms),
          const SizedBox(height: 28),

          _GroupHeader(label: l10n.onboardingExpensesGroup),
          const SizedBox(height: 12),
          _CategoryGrid(
            presets: expenses,
            customs: customExpenses,
            onToggle: (p) => setState(() => p.selected = !p.selected),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
          const SizedBox(height: 8),
          _AddCustomButton(
            label: l10n.onboardingAddCustomCategory,
            onTap: () => _showCustomForm(_Group.expense),
          ),
          const SizedBox(height: 24),

          _GroupHeader(label: l10n.onboardingIncomeGroup),
          const SizedBox(height: 12),
          _CategoryGrid(
            presets: income,
            customs: customIncome,
            onToggle: (p) => setState(() => p.selected = !p.selected),
          ).animate().fadeIn(duration: 300.ms, delay: 140.ms),
          const SizedBox(height: 8),
          _AddCustomButton(
            label: l10n.onboardingAddCustomCategory,
            onTap: () => _showCustomForm(_Group.income),
          ),
          const SizedBox(height: 32),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _error!,
                style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
              ),
            ),

          FilledButton(
            onPressed: (_hasSelection && !_isSaving) ? _finish : null,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(l10n.onboardingFinishButton),
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.presets,
    required this.customs,
    required this.onToggle,
  });

  final List<_Preset> presets;
  final List<_Custom> customs;
  final void Function(_Preset) onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...presets.map((p) => _CategoryChip(
              icon: p.icon,
              name: p.name,
              selected: p.selected,
              onTap: () => onToggle(p),
            )),
        ...customs.map((c) => _CategoryChip(
              icon: c.icon,
              name: c.name,
              selected: true,
              onTap: null,
            )),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.icon,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String icon;
  final String name;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal50 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.teal400 : AppColors.neutral200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: selected ? AppColors.teal400 : AppColors.neutral600,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
            if (selected) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check, size: 14, color: AppColors.teal400),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddCustomButton extends StatelessWidget {
  const _AddCustomButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add_circle_outline, size: 16, color: AppColors.navy400),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.navy400,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class _CustomCategorySheet extends StatefulWidget {
  const _CustomCategorySheet({required this.group});
  final _Group group;

  @override
  State<_CustomCategorySheet> createState() => _CustomCategorySheetState();
}

class _CustomCategorySheetState extends State<_CustomCategorySheet> {
  final _nameController = TextEditingController();
  String _selectedIcon = '🎯';
  String _selectedColor = '#16A34A';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(_Custom(
      name: name,
      icon: _selectedIcon,
      color: _selectedColor,
      group: widget.group,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final padding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.onboardingNewCategoryTitle,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(hintText: l10n.onboardingCategoryNameHint),
          ),
          const SizedBox(height: 16),

          Text(l10n.onboardingIconSectionLabel, style: textTheme.labelMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: GridView.count(
              crossAxisCount: 8,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: _kEmojiOptions.map((emoji) {
                final isSelected = emoji == _selectedIcon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = emoji),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.teal50 : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.teal400 : Colors.transparent,
                      ),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          Text(l10n.colorLabel, style: textTheme.labelMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: kCategoryPresetColors.map((hex) {
              final isSelected =
                  hex.toLowerCase() == _selectedColor.toLowerCase();
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = hex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: hexToColor(hex),
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: isSelected
                        ? [BoxShadow(color: hexToColor(hex).withValues(alpha: 0.5), blurRadius: 6)]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          FilledButton(
            onPressed: _nameController.text.trim().isEmpty ? null : _submit,
            child: Text(l10n.onboardingAddButton),
          ),
        ],
      ),
    );
  }
}
