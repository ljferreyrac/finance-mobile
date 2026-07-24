import 'package:equatable/equatable.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class LoadAccounts extends AccountEvent {
  const LoadAccounts({this.includeDebt = true});

  final bool includeDebt;

  @override
  List<Object?> get props => [includeDebt];
}

class CreateAccount extends AccountEvent {
  const CreateAccount(this.body);

  final Map<String, dynamic> body;

  @override
  List<Object?> get props => [body];
}

class UpdateAccount extends AccountEvent {
  const UpdateAccount(this.id, this.body);

  final String id;
  final Map<String, dynamic> body;

  @override
  List<Object?> get props => [id, body];
}

class DeleteAccount extends AccountEvent {
  const DeleteAccount(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class SetDefaultAccount extends AccountEvent {
  const SetDefaultAccount(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
