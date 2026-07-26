import 'package:dio/dio.dart';

import '../../../shared/models/failure.dart';
import '../../../shared/utils/dio_error_mapper.dart';
import '../models/category_model.dart';
import 'category_api_service.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> listCategories();
  Future<CategoryModel> createCategory({
    required String name,
    String? color,
    String? icon,
    bool isDefault = false,
  });
  Future<CategoryModel> updateCategory(
    String id, {
    String? name,
    String? color,
    String? icon,
    int? position,
  });
  Future<void> deleteCategory(String id, {String? reassignTo});
  Future<CategoryModel> setDefault(String id);
}

/// Default implementation backed by [CategoryApiService].
///
/// All [DioException]s are caught and re-thrown as typed [Failure] subclasses
/// so that BLoC handlers never import Dio directly.
class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl({CategoryApiService? apiService})
      : _api = apiService ?? CategoryApiService();

  final CategoryApiService _api;

  @override
  Future<List<CategoryModel>> listCategories() =>
      _run(() => _api.getCategories());

  @override
  Future<CategoryModel> createCategory({
    required String name,
    String? color,
    String? icon,
    bool isDefault = false,
  }) =>
      _run(() => _api.createCategory(
            name: name,
            color: color,
            icon: icon,
            isDefault: isDefault,
          ));

  @override
  Future<CategoryModel> updateCategory(
    String id, {
    String? name,
    String? color,
    String? icon,
    int? position,
  }) =>
      _run(() => _api.updateCategory(
            id,
            name: name,
            color: color,
            icon: icon,
            position: position,
          ));

  @override
  Future<void> deleteCategory(String id, {String? reassignTo}) =>
      _run(() => _api.deleteCategory(id, reassignTo: reassignTo));

  @override
  Future<CategoryModel> setDefault(String id) =>
      _run(() => _api.setDefault(id));

  /// Wraps [action] and maps [DioException] to a typed [Failure].
  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (e) {
      throw mapDioError(e);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
