import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../bloc/tag_bloc.dart';
import '../bloc/tag_event.dart';
import '../bloc/tag_state.dart';
import '../models/tag_model.dart';
import '../../categories/widgets/category_color_picker.dart';
import 'tag_form_screen.dart';
import '../../../core/widgets/app_snack_bar.dart';

/// Full-page screen for managing the user's tags.
///
/// [TagBloc] must be provided above this route.
class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  @override
  void initState() {
    super.initState();
    final state = context.read<TagBloc>().state;
    if (state is TagInitial) {
      context.read<TagBloc>().add(const LoadTags());
    }
  }

  Future<void> _openForm({TagModel? tag}) async {
    final tagBloc = context.read<TagBloc>();
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: tagBloc,
          child: TagFormScreen(initialTag: tag),
        ),
      ),
    );
    // No manual refresh needed: TagBloc already holds the refreshed list.
  }

  Future<void> _onDelete(TagModel tag) async {
    final confirmed = await _showConfirmDeleteDialog(tag);
    if (confirmed != true) return;
    if (!mounted) return;
    context.read<TagBloc>().add(DeleteTag(tag.id));
  }

  Future<bool?> _showConfirmDeleteDialog(TagModel tag) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteTagConfirm),
        content: Text(l10n.deleteTagMessage(tag.name)),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.tagsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: AppLocalizations.of(context)!.newTag,
            onPressed: () => _openForm(),
          ),
        ],
      ),
      body: BlocConsumer<TagBloc, TagState>(
        listener: (context, state) {
          if (state is TagError) {
            AppSnackBar.showError(
              context,
              state.message,
              actionLabel: AppLocalizations.of(context)!.retry,
              onAction: () => context.read<TagBloc>().add(const LoadTags()),
            );
          }
        },
        builder: (context, state) {
          if (state is TagLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<TagModel> tags;
          if (state is TagLoaded) {
            tags = state.tags;
          } else if (state is TagError) {
            return _ErrorBody(
              message: state.message,
              onRetry: () =>
                  context.read<TagBloc>().add(const LoadTags()),
            );
          } else {
            return const SizedBox.shrink();
          }

          if (tags.isEmpty) {
            return const _EmptyBody();
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: tags.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final tag = tags[index];
              return _TagListTile(
                tag: tag,
                onEdit: () => _openForm(tag: tag),
                onDelete: () => _onDelete(tag),
              );
            },
          );
        },
      ),
    );
  }
}

class _TagListTile extends StatelessWidget {
  const _TagListTile({
    required this.tag,
    required this.onEdit,
    required this.onDelete,
  });

  final TagModel tag;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dotColor = tag.color != null
        ? hexToColor(tag.color!)
        : const Color(0xFF6B7280);

    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: dotColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          tag.name.isNotEmpty ? tag.name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      title: Text(
        tag.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: PopupMenuButton<_MenuAction>(
        onSelected: (action) {
          switch (action) {
            case _MenuAction.edit:
              onEdit();
            case _MenuAction.delete:
              onDelete();
          }
        },
        itemBuilder: (ctx) {
          final l10n = AppLocalizations.of(ctx)!;
          return [
            PopupMenuItem(
              value: _MenuAction.edit,
              child: Text(l10n.edit),
            ),
            PopupMenuItem(
              value: _MenuAction.delete,
              child: Text(
                l10n.delete,
                style: TextStyle(color: colorScheme.error),
              ),
            ),
          ];
        },
      ),
    );
  }
}

enum _MenuAction { edit, delete }

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.label_outline,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.emptyTags,
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
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }
}
