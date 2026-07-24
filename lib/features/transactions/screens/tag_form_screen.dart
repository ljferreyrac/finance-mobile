import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../bloc/tag_bloc.dart';
import '../bloc/tag_event.dart';
import '../bloc/tag_state.dart';
import '../models/tag_model.dart';
import '../../categories/widgets/category_color_picker.dart';
import '../../../core/widgets/app_snack_bar.dart';

/// Create / edit screen for a single tag.
///
/// When [initialTag] is provided the form is in edit mode.
/// [TagBloc] must be provided above this route.
class TagFormScreen extends StatefulWidget {
  const TagFormScreen({super.key, this.initialTag});

  final TagModel? initialTag;

  @override
  State<TagFormScreen> createState() => _TagFormScreenState();
}

class _TagFormScreenState extends State<TagFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  String? _color;
  bool _isSubmitting = false;

  bool get _isEditMode => widget.initialTag != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialTag;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _color = initial?.color;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickColor() async {
    final picked = await showCategoryColorPicker(context, current: _color);
    if (picked != null) setState(() => _color = picked);
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final name = _nameController.text.trim();
    if (_isEditMode) {
      context.read<TagBloc>().add(
            UpdateTag(
              id: widget.initialTag!.id,
              name: name,
              color: _color,
            ),
          );
    } else {
      context.read<TagBloc>().add(
            CreateTag(name: name, color: _color),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<TagBloc, TagState>(
      listener: (context, state) {
        if (state is TagLoaded) {
          setState(() => _isSubmitting = false);
          Navigator.of(context).pop(true);
        }
        if (state is TagError) {
          setState(() => _isSubmitting = false);
          AppSnackBar.showError(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditMode
              ? AppLocalizations.of(context)!.editTag
              : AppLocalizations.of(context)!.newTag),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.tagNameLabel,
                  hintText: AppLocalizations.of(context)!.tagNameHint,
                  prefixIcon: const Icon(Icons.label_outline),
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLength: 50,
                buildCounter: (
                  _, {
                  required currentLength,
                  required isFocused,
                  maxLength,
                }) =>
                    null,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return AppLocalizations.of(context)!.tagNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: _pickColor,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.tagColorLabel,
                    prefixIcon: const Icon(Icons.palette_outlined),
                    border: const OutlineInputBorder(),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _color != null
                              ? hexToColor(_color!)
                              : colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _color ?? AppLocalizations.of(context)!.noColor,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (_color != null) ...[
                        const Spacer(),
                        GestureDetector(
                          onTap: () => setState(() => _color = null),
                          child: Icon(
                            Icons.clear,
                            size: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D9E75),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isEditMode
                              ? AppLocalizations.of(context)!.saveChanges
                              : AppLocalizations.of(context)!.createTag,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
