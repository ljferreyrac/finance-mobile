import 'package:equatable/equatable.dart';

/// Events dispatched to [CategoryBloc].
abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {
  const LoadCategories();
}

class CreateCategory extends CategoryEvent {
  const CreateCategory({
    required this.name,
    this.color,
    this.icon,
    this.isDefault = false,
  });

  final String name;
  final String? color;
  final String? icon;
  final bool isDefault;

  @override
  List<Object?> get props => [name, color, icon, isDefault];
}

class UpdateCategory extends CategoryEvent {
  const UpdateCategory({
    required this.id,
    this.name,
    this.color,
    this.icon,
    this.position,
  });

  final String id;
  final String? name;
  final String? color;
  final String? icon;
  final int? position;

  @override
  List<Object?> get props => [id, name, color, icon, position];
}

/// When [reassignTo] is null and the category has expenses, the backend may
/// reject the request; the UI prompts the user to pick a replacement first.
class DeleteCategory extends CategoryEvent {
  const DeleteCategory({required this.id, this.reassignTo});

  final String id;

  /// UUID of the category to reassign existing expenses to.
  final String? reassignTo;

  @override
  List<Object?> get props => [id, reassignTo];
}

class SetDefaultCategory extends CategoryEvent {
  const SetDefaultCategory({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}
