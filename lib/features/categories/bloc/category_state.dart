import 'package:equatable/equatable.dart';

import '../models/category_model.dart';

/// States emitted by [CategoryBloc].
abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

class CategoryLoaded extends CategoryState {
  const CategoryLoaded(this.categories);

  final List<CategoryModel> categories;

  /// Returns the category marked as default, or null when none is set.
  CategoryModel? get defaultCategory =>
      categories.where((c) => c.isDefault).firstOrNull;

  @override
  List<Object?> get props => [categories];
}

/// An error occurred; [message] is shown to the user.
class CategoryError extends CategoryState {
  const CategoryError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// A create / update / delete / set-default action succeeded.
///
/// Carries the refreshed full list so the UI can update without an extra
/// round-trip, plus a [message] for the SnackBar confirmation.
class CategoryActionSuccess extends CategoryState {
  const CategoryActionSuccess({
    required this.categories,
    required this.message,
  });

  final List<CategoryModel> categories;
  final String message;

  /// Returns the category marked as default, or null when none is set.
  CategoryModel? get defaultCategory =>
      categories.where((c) => c.isDefault).firstOrNull;

  @override
  List<Object?> get props => [categories, message];
}
