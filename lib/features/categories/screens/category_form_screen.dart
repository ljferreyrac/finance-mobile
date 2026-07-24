import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';
import '../models/category_model.dart';
import '../widgets/category_color_picker.dart';
import '../widgets/category_icon_picker.dart';
import '../../../core/widgets/app_snack_bar.dart';

/// Create / edit screen for a single category.
///
/// When [initialCategory] is provided the form is in edit mode.
/// [CategoryBloc] must be provided above this route.
class CategoryFormScreen extends StatefulWidget {
  const CategoryFormScreen({super.key, this.initialCategory});

  final CategoryModel? initialCategory;

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  String? _color;
  String? _icon;
  late bool _isDefault;
  bool _isSubmitting = false;

  bool get _isEditMode => widget.initialCategory != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialCategory;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _color = initial?.color;
    _icon = initial?.icon;
    _isDefault = initial?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickColor() async {
    final picked =
        await showCategoryColorPicker(context, current: _color);
    if (picked != null) setState(() => _color = picked);
  }

  Future<void> _pickIcon() async {
    final picked = await showCategoryIconPicker(context, current: _icon);
    if (picked != null) setState(() => _icon = picked);
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final name = _nameController.text.trim();
    if (_isEditMode) {
      context.read<CategoryBloc>().add(
            UpdateCategory(
              id: widget.initialCategory!.id,
              name: name,
              color: _color,
              icon: _icon,
            ),
          );
    } else {
      context.read<CategoryBloc>().add(
            CreateCategory(
              name: name,
              color: _color,
              icon: _icon,
              isDefault: _isDefault,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryActionSuccess) {
          setState(() => _isSubmitting = false);
          Navigator.of(context).pop(true);
        }
        if (state is CategoryError) {
          setState(() => _isSubmitting = false);
          AppSnackBar.showError(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditMode
              ? AppLocalizations.of(context)!.editCategory
              : AppLocalizations.of(context)!.newCategory),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.categoryNameLabel,
                  hintText: AppLocalizations.of(context)!.categoryNameHint,
                  prefixIcon: const Icon(Icons.label_outline),
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLength: 100,
                buildCounter: (
                  _, {
                  required currentLength,
                  required isFocused,
                  maxLength,
                }) =>
                    null,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return AppLocalizations.of(context)!.categoryNameRequired;
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
                    labelText: AppLocalizations.of(context)!.categoryColorLabel,
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: _pickIcon,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.categoryIconLabel,
                    prefixIcon: const Icon(Icons.emoji_emotions_outlined),
                    border: const OutlineInputBorder(),
                  ),
                  child: Row(
                    children: [
                      if (_icon != null)
                        Text(_icon!, style: const TextStyle(fontSize: 24))
                      else
                        Text(
                          AppLocalizations.of(context)!.noIcon,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              if (!_isEditMode)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppLocalizations.of(context)!.defaultCategory),
                  subtitle: Text(
                    AppLocalizations.of(context)!.defaultCategorySubtitle,
                  ),
                  value: _isDefault,
                  onChanged: (v) => setState(() => _isDefault = v),
                  activeThumbColor: colorScheme.primary,
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
                              : AppLocalizations.of(context)!.createCategory,
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
