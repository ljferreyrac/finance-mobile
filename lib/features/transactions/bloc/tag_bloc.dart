import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/failure.dart';
import '../data/tag_repository.dart';
import 'tag_event.dart';
import 'tag_state.dart';

/// Manages the user's tag collection.
///
/// All mutation events ([CreateTag], [UpdateTag], [DeleteTag]) re-fetch the
/// full list after success so that [TagLoaded] always reflects the latest
/// server state.
class TagBloc extends Bloc<TagEvent, TagState> {
  TagBloc({required TagRepository repository})
      : _repository = repository,
        super(const TagInitial()) {
    on<LoadTags>(_onLoad);
    on<CreateTag>(_onCreate);
    on<UpdateTag>(_onUpdate);
    on<DeleteTag>(_onDelete);
  }

  final TagRepository _repository;

  Future<void> _onLoad(
    LoadTags event,
    Emitter<TagState> emit,
  ) async {
    emit(const TagLoading());
    try {
      final tags = await _repository.getTags();
      emit(TagLoaded(tags));
    } on Failure catch (f) {
      emit(TagError(f.message));
    } catch (e) {
      emit(TagError(e.toString()));
    }
  }

  Future<void> _onCreate(
    CreateTag event,
    Emitter<TagState> emit,
  ) async {
    emit(const TagLoading());
    try {
      await _repository.createTag(event.name, event.color);
      final tags = await _repository.getTags();
      emit(TagLoaded(tags));
    } on Failure catch (f) {
      emit(TagError(f.message));
    } catch (e) {
      emit(TagError(e.toString()));
    }
  }

  Future<void> _onUpdate(
    UpdateTag event,
    Emitter<TagState> emit,
  ) async {
    emit(const TagLoading());
    try {
      await _repository.updateTag(event.id, name: event.name, color: event.color);
      final tags = await _repository.getTags();
      emit(TagLoaded(tags));
    } on Failure catch (f) {
      emit(TagError(f.message));
    } catch (e) {
      emit(TagError(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteTag event,
    Emitter<TagState> emit,
  ) async {
    emit(const TagLoading());
    try {
      await _repository.deleteTag(event.id);
      final tags = await _repository.getTags();
      emit(TagLoaded(tags));
    } on Failure catch (f) {
      emit(TagError(f.message));
    } catch (e) {
      emit(TagError(e.toString()));
    }
  }
}
