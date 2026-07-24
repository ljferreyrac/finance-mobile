import 'package:dio/dio.dart';

import '../../../core/api/dio_client.dart';
import '../models/tag_model.dart';

/// Raw HTTP calls against the tags API endpoints.
///
/// Throws [DioException] on non-2xx responses. The repository layer
/// converts those into typed [Failure] objects.
class TagApiService {
  TagApiService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  static const String _path = '/tags';

  Future<List<TagModel>> fetchTags() async {
    final response = await _dio.get<List<dynamic>>(_path);
    return (response.data!)
        .cast<Map<String, dynamic>>()
        .map(TagModel.fromJson)
        .toList();
  }

  Future<TagModel> createTag(String name, String? color) async {
    final body = <String, dynamic>{
      'name': name,
      if (color != null) 'color': color,
    };
    final response = await _dio.post<Map<String, dynamic>>(_path, data: body);
    return TagModel.fromJson(response.data!);
  }

  Future<TagModel> updateTag(String id, {String? name, String? color}) async {
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (color != null) 'color': color,
    };
    final response =
        await _dio.put<Map<String, dynamic>>('$_path/$id', data: body);
    return TagModel.fromJson(response.data!);
  }

  Future<void> deleteTag(String id) async {
    await _dio.delete('$_path/$id');
  }
}
