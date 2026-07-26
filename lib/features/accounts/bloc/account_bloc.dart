import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/failure.dart';
import '../../../shared/models/failure_code.dart';
import '../../../shared/models/localized_message.dart';
import '../data/account_repository.dart';
import '../models/account_model.dart';
import 'account_event.dart';
import 'account_state.dart';

/// Manages the full lifecycle of account CRUD operations and net worth display.
class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc({required AccountRepository repository})
      : _repository = repository,
        super(const AccountInitial()) {
    on<LoadAccounts>(_onLoad);
    on<CreateAccount>(_onCreate);
    on<UpdateAccount>(_onUpdate);
    on<DeleteAccount>(_onDelete);
    on<SetDefaultAccount>(_onSetDefault);
  }

  final AccountRepository _repository;

  /// Persisted across events so all subsequent reloads use the same preference.
  bool _includeDebt = true;

  Future<void> _onLoad(
    LoadAccounts event,
    Emitter<AccountState> emit,
  ) async {
    _includeDebt = event.includeDebt;
    emit(const AccountLoading());
    try {
      final results = await Future.wait([
        _repository.getAccounts(),
        _repository.getNetWorth(includeDebt: _includeDebt),
      ]);
      final accounts = results[0] as List<AccountModel>;
      final netWorth = results[1] as NetWorthModel;
      emit(AccountLoaded(accounts: accounts, netWorth: netWorth));
    } on Failure catch (f) {
      emit(AccountError(LocalizedMessage.raw(f.message)));
    } catch (e) {
      emit(AccountError(LocalizedMessage.raw(e.toString())));
    }
  }

  Future<void> _onCreate(
    CreateAccount event,
    Emitter<AccountState> emit,
  ) async {
    emit(const AccountLoading());
    try {
      await _repository.createAccount(event.body);
      final results = await Future.wait([
        _repository.getAccounts(),
        _repository.getNetWorth(includeDebt: _includeDebt),
      ]);
      final accounts = results[0] as List<AccountModel>;
      final netWorth = results[1] as NetWorthModel;
      emit(AccountOperationSuccess(
        accounts: accounts,
        netWorth: netWorth,
        message: const LocalizedMessage.code(FailureCode.accountCreated),
      ));
    } on Failure catch (f) {
      emit(AccountError(LocalizedMessage.raw(f.message)));
    } catch (e) {
      emit(AccountError(LocalizedMessage.raw(e.toString())));
    }
  }

  Future<void> _onUpdate(
    UpdateAccount event,
    Emitter<AccountState> emit,
  ) async {
    emit(const AccountLoading());
    try {
      await _repository.updateAccount(event.id, event.body);
      final results = await Future.wait([
        _repository.getAccounts(),
        _repository.getNetWorth(includeDebt: _includeDebt),
      ]);
      final accounts = results[0] as List<AccountModel>;
      final netWorth = results[1] as NetWorthModel;
      emit(AccountOperationSuccess(
        accounts: accounts,
        netWorth: netWorth,
        message: const LocalizedMessage.code(FailureCode.accountUpdated),
      ));
    } on Failure catch (f) {
      emit(AccountError(LocalizedMessage.raw(f.message)));
    } catch (e) {
      emit(AccountError(LocalizedMessage.raw(e.toString())));
    }
  }

  Future<void> _onDelete(
    DeleteAccount event,
    Emitter<AccountState> emit,
  ) async {
    emit(const AccountLoading());
    try {
      await _repository.deleteAccount(event.id);
      final results = await Future.wait([
        _repository.getAccounts(),
        _repository.getNetWorth(includeDebt: _includeDebt),
      ]);
      final accounts = results[0] as List<AccountModel>;
      final netWorth = results[1] as NetWorthModel;
      emit(AccountOperationSuccess(
        accounts: accounts,
        netWorth: netWorth,
        message: const LocalizedMessage.code(FailureCode.accountDeleted),
      ));
    } on Failure catch (f) {
      emit(AccountError(LocalizedMessage.raw(f.message)));
    } catch (e) {
      emit(AccountError(LocalizedMessage.raw(e.toString())));
    }
  }

  Future<void> _onSetDefault(
    SetDefaultAccount event,
    Emitter<AccountState> emit,
  ) async {
    emit(const AccountLoading());
    try {
      await _repository.setDefaultAccount(event.id);
      final results = await Future.wait([
        _repository.getAccounts(),
        _repository.getNetWorth(includeDebt: _includeDebt),
      ]);
      final accounts = results[0] as List<AccountModel>;
      final netWorth = results[1] as NetWorthModel;
      emit(AccountOperationSuccess(
        accounts: accounts,
        netWorth: netWorth,
        message: const LocalizedMessage.code(FailureCode.accountSetDefault),
      ));
    } on Failure catch (f) {
      emit(AccountError(LocalizedMessage.raw(f.message)));
    } catch (e) {
      emit(AccountError(LocalizedMessage.raw(e.toString())));
    }
  }
}
