import 'package:equatable/equatable.dart';

import '../../../shared/models/localized_message.dart';
import '../models/account_model.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {
  const AccountInitial();
}

/// Also emitted while a create/update/delete/setDefault mutation runs, not
/// just the initial fetch.
class AccountLoading extends AccountState {
  const AccountLoading();
}

class AccountLoaded extends AccountState {
  const AccountLoaded({
    required this.accounts,
    required this.netWorth,
  });

  final List<AccountModel> accounts;
  final NetWorthModel netWorth;

  @override
  List<Object?> get props => [accounts, netWorth];
}

/// Carries the refreshed accounts/net worth so the UI updates without an
/// extra round-trip after a mutation.
class AccountOperationSuccess extends AccountState {
  const AccountOperationSuccess({
    required this.accounts,
    required this.netWorth,
    required this.message,
  });

  final List<AccountModel> accounts;
  final NetWorthModel netWorth;
  final LocalizedMessage message;

  @override
  List<Object?> get props => [accounts, netWorth, message];
}

class AccountError extends AccountState {
  const AccountError(this.message);

  final LocalizedMessage message;

  @override
  List<Object?> get props => [message];
}
