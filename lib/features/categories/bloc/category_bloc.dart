import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/failure.dart';
import '../../../shared/models/failure_code.dart';
import '../../../shared/models/localized_message.dart';
import '../data/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

/// Manages the full lifecycle of category CRUD operations.
///
/// After every successful mutation the full list is re-fetched from the
/// server so the UI always reflects the authoritative state (correct
/// positions, default flag, updated expense counts).
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc({required CategoryRepository repository})
      : _repository = repository,
        super(const CategoryInitial()) {
    on<LoadCategories>(_onLoad);
    on<CreateCategory>(_onCreate);
    on<UpdateCategory>(_onUpdate);
    on<DeleteCategory>(_onDelete);
    on<SetDefaultCategory>(_onSetDefault);
  }

  final CategoryRepository _repository;

  Future<void> _onLoad(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    try {
      final categories = await _repository.listCategories();
      emit(CategoryLoaded(categories));
    } on Failure catch (f) {
      emit(CategoryError(LocalizedMessage.raw(f.message)));
    } catch (e) {
      emit(CategoryError(LocalizedMessage.raw(e.toString())));
    }
  }

  Future<void> _onCreate(
    CreateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    try {
      await _repository.createCategory(
        name: event.name,
        color: event.color,
        icon: event.icon,
        isDefault: event.isDefault,
      );
      final categories = await _repository.listCategories();
      emit(CategoryActionSuccess(
        categories: categories,
        message: const LocalizedMessage.code(FailureCode.categoryCreated),
      ));
    } on Failure catch (f) {
      emit(CategoryError(LocalizedMessage.raw(f.message)));
    } catch (e) {
      emit(CategoryError(LocalizedMessage.raw(e.toString())));
    }
  }

  Future<void> _onUpdate(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    try {
      await _repository.updateCategory(
        event.id,
        name: event.name,
        color: event.color,
        icon: event.icon,
        position: event.position,
      );
      final categories = await _repository.listCategories();
      emit(CategoryActionSuccess(
        categories: categories,
        message: const LocalizedMessage.code(FailureCode.categoryUpdated),
      ));
    } on Failure catch (f) {
      emit(CategoryError(LocalizedMessage.raw(f.message)));
    } catch (e) {
      emit(CategoryError(LocalizedMessage.raw(e.toString())));
    }
  }

  Future<void> _onDelete(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    try {
      await _repository.deleteCategory(
        event.id,
        reassignTo: event.reassignTo,
      );
      final categories = await _repository.listCategories();
      emit(CategoryActionSuccess(
        categories: categories,
        message: const LocalizedMessage.code(FailureCode.categoryDeleted),
      ));
    } on Failure catch (f) {
      emit(CategoryError(LocalizedMessage.raw(f.message)));
    } catch (e) {
      emit(CategoryError(LocalizedMessage.raw(e.toString())));
    }
  }

  Future<void> _onSetDefault(
    SetDefaultCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    try {
      await _repository.setDefault(event.id);
      final categories = await _repository.listCategories();
      emit(CategoryActionSuccess(
        categories: categories,
        message: const LocalizedMessage.code(FailureCode.categorySetDefault),
      ));
    } on Failure catch (f) {
      emit(CategoryError(LocalizedMessage.raw(f.message)));
    } catch (e) {
      emit(CategoryError(LocalizedMessage.raw(e.toString())));
    }
  }
}
