import 'package:equatable/equatable.dart';

/// Events dispatched to [TagBloc].
abstract class TagEvent extends Equatable {
  const TagEvent();

  @override
  List<Object?> get props => [];
}

/// Loads (or reloads) the full list of tags for the current user.
class LoadTags extends TagEvent {
  const LoadTags();
}

class CreateTag extends TagEvent {
  const CreateTag({required this.name, this.color});

  final String name;
  final String? color;

  @override
  List<Object?> get props => [name, color];
}

/// Only non-null fields are sent to the API when updating [id].
class UpdateTag extends TagEvent {
  const UpdateTag({required this.id, this.name, this.color});

  final String id;
  final String? name;
  final String? color;

  @override
  List<Object?> get props => [id, name, color];
}

class DeleteTag extends TagEvent {
  const DeleteTag(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
