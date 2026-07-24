import 'package:equatable/equatable.dart';

import '../models/tag_model.dart';

/// States emitted by [TagBloc].
abstract class TagState extends Equatable {
  const TagState();

  @override
  List<Object?> get props => [];
}

class TagInitial extends TagState {
  const TagInitial();
}

/// Tags are being fetched, or a mutation is in flight.
class TagLoading extends TagState {
  const TagLoading();
}

/// Also emitted after a successful create/update/delete so consumers always
/// get the refreshed list.
class TagLoaded extends TagState {
  const TagLoaded(this.tags);

  final List<TagModel> tags;

  @override
  List<Object?> get props => [tags];
}

class TagError extends TagState {
  const TagError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
