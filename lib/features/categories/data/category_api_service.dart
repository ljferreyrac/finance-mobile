import 'package:dio/dio.dart';

import '../../../core/api/dio_client.dart';
import '../models/category_model.dart';

/// Raw HTTP calls against the categories API endpoints.
///
/// Throws [DioException] on non-2xx responses. The repository layer
/// converts those into typed [Failure] objects.
class CategoryApiService {
  CategoryApiService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  static const String _path = '/categories';

  Future<List<CategoryModel>> getCategories() async {
    final response = await _dio.get<List<dynamic>>(_path);
    final list = response.data!;
    return list
        .cast<Map<String, dynamic>>()
        .map(CategoryModel.fromJson)
        .toList();
  }

  Future<CategoryModel> createCategory({
    required String name,
    String? color,
    String? icon,
    bool isDefault = false,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      'isDefault': isDefault,
    };
    final response =
        await _dio.post<Map<String, dynamic>>(_path, data: body);
    return CategoryModel.fromJson(response.data!);
  }

  Future<CategoryModel> updateCategory(
    String id, {
    String? name,
    String? color,
    String? icon,
    int? position,
  }) async {
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (position != null) 'position': position,
    };
    final response =
        await _dio.put<Map<String, dynamic>>('$_path/$id', data: body);
    return CategoryModel.fromJson(response.data!);
  }

  Future<void> deleteCategory(String id, {String? reassignTo}) async {
    await _dio.delete(
      '$_path/$id',
      queryParameters: {
        if (reassignTo != null) 'reassignTo': reassignTo,
      },
    );
  }

  Future<CategoryModel> setDefault(String id) async {
    final response =
        await _dio.patch<Map<String, dynamic>>('$_path/$id/default');
    return CategoryModel.fromJson(response.data!);
  }
}
