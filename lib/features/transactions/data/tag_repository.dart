import 'package:dio/dio.dart';

import '../../../shared/models/failure.dart';
import '../../../shared/utils/dio_error_mapper.dart';
import '../models/tag_model.dart';
import 'tag_api_service.dart';

/// Contract for tag data access.
abstract class TagRepository {
  Future<List<TagModel>> getTags();
  Future<TagModel> createTag(String name, String? color);
  Future<TagModel> updateTag(String id, {String? name, String? color});
  Future<void> deleteTag(String id);
}

/// Default implementation backed by [TagApiService].
///
/// All [DioException]s are caught and re-thrown as typed [Failure] subclasses
/// so that BLoC handlers never import Dio directly.
class TagRepositoryImpl implements TagRepository {
  TagRepositoryImpl({TagApiService? apiService})
      : _api = apiService ?? TagApiService();

  final TagApiService _api;

  @override
  Future<List<TagModel>> getTags() => _run(() => _api.fetchTags());

  @override
  Future<TagModel> createTag(String name, String? color) =>
      _run(() => _api.createTag(name, color));

  @override
  Future<TagModel> updateTag(String id, {String? name, String? color}) =>
      _run(() => _api.updateTag(id, name: name, color: color));

  @override
  Future<void> deleteTag(String id) => _run(() => _api.deleteTag(id));

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
