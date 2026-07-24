import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../bloc/tag_bloc.dart';
import '../bloc/tag_event.dart';
import '../bloc/tag_state.dart';
import '../models/tag_model.dart';
import 'tag_chip.dart';
import '../../../core/widgets/app_snack_bar.dart';

/// Preset hex colors offered when creating a new tag inline.
const List<String> _kTagPresetColors = [
  '#4CAF50',
  '#2196F3',
  '#FF5733',
  '#FF9800',
  '#9C27B0',
  '#607D8B',
];

/// Shows a modal bottom sheet that lets the user pick tags for a transaction.
///
/// - Displays all existing tags as selectable chips.
/// - The current [selected] tags start pre-checked.
/// - A search field filters the list in real time.
/// - When the search text does not match any tag a "Create new tag" row
///   appears with an inline color picker (6 presets).
///
/// Resolves with the final [List<TagModel>] selection, or the original
/// [selected] list if the user dismisses without confirming.
Future<List<TagModel>> showTagPickerSheet(
  BuildContext context, {
  required List<TagModel> selected,
  required TagBloc tagBloc,
}) {
  return showModalBottomSheet<List<TagModel>>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => BlocProvider.value(
      value: tagBloc,
      child: _TagPickerSheet(initialSelected: selected),
    ),
  ).then((result) => result ?? selected);
}

class _TagPickerSheet extends StatefulWidget {
  const _TagPickerSheet({required this.initialSelected});

  final List<TagModel> initialSelected;

  @override
  State<_TagPickerSheet> createState() => _TagPickerSheetState();
}

class _TagPickerSheetState extends State<_TagPickerSheet> {
  final _searchController = TextEditingController();

  late List<TagModel> _selected;
  String _query = '';
  String? _newTagColor;

  @override
  void initState() {
    super.initState();
    _selected = List.of(widget.initialSelected);
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });

    final tagState = context.read<TagBloc>().state;
    if (tagState is TagInitial) {
      context.read<TagBloc>().add(const LoadTags());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isSelected(TagModel tag) => _selected.any((t) => t.id == tag.id);

  void _toggle(TagModel tag) {
    setState(() {
      if (_isSelected(tag)) {
        _selected.removeWhere((t) => t.id == tag.id);
      } else {
        _selected.add(tag);
      }
    });
  }

  void _createTag(List<TagModel> existingTags) {
    if (_query.isEmpty) return;
    // Prevent duplicates by name.
    final exists = existingTags.any(
      (t) => t.name.toLowerCase() == _query,
    );
    if (exists) return;
    context.read<TagBloc>().add(
          CreateTag(name: _searchController.text.trim(), color: _newTagColor),
        );
    _searchController.clear();
    setState(() => _newTagColor = null);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<TagBloc, TagState>(
      listener: (context, state) {
        // When a create lands, auto-select the newest tag (last in list).
        if (state is TagLoaded && state.tags.isNotEmpty) {
          final newest = state.tags.last;
          if (!_isSelected(newest) &&
              newest.name.toLowerCase().contains(_query)) {
            setState(() => _selected.add(newest));
          }
        }
        if (state is TagError) {
          AppSnackBar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final allTags = state is TagLoaded ? state.tags : <TagModel>[];
        final isLoading = state is TagLoading;

        final filtered = _query.isEmpty
            ? allTags
            : allTags
                .where((t) => t.name.toLowerCase().contains(_query))
                .toList();

        final showCreateRow = _query.isNotEmpty &&
            !allTags.any((t) => t.name.toLowerCase() == _query);

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.tagsTitle,
                          style: textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(_selected),
                        child: Text(AppLocalizations.of(context)!.done),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    autofocus: false,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.searchOrCreateTag,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: _searchController.clear,
                            )
                          : null,
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                const SizedBox(height: 12),

                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ...filtered.map((tag) {
                                final selected = _isSelected(tag);
                                return GestureDetector(
                                  onTap: () => _toggle(tag),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    decoration: selected
                                        ? BoxDecoration(
                                            border: Border.all(
                                              color: colorScheme.primary,
                                              width: 2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(32),
                                          )
                                        : null,
                                    child: TagChip(tag: tag),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                ),

                if (showCreateRow) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      AppLocalizations.of(context)!.newTagColor,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _kTagPresetColors.map((hex) {
                        final isChosen =
                            _newTagColor?.toLowerCase() == hex.toLowerCase();
                        final color = _hexToColor(hex);
                        return GestureDetector(
                          onTap: () => setState(() => _newTagColor =
                              isChosen ? null : hex),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isChosen
                                  ? Border.all(
                                      color: colorScheme.onSurface,
                                      width: 2.5,
                                    )
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
                  ),
                  ListTile(
                    leading: Icon(Icons.add, color: colorScheme.primary),
                    title: Text(
                      AppLocalizations.of(context)!.createTagInline(
                          _searchController.text.trim()),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () => _createTag(allTags),
                  ),
                ],

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  static Color _hexToColor(String hex) =>
      Color(int.parse('0xFF${hex.replaceAll('#', '')}'));
}
