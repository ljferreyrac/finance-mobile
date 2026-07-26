import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/onboarding_service.dart';
import '../../../core/services/token_storage.dart';
import '../../../features/categories/data/category_repository.dart';
import '../../../shared/models/failure.dart';
import '../../../shared/models/failure_code.dart';
import '../../../shared/models/localized_message.dart';
import '../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Manages authentication state: initial check, login, register, and logout.
///
/// The BLoC never owns navigation logic - it only emits states. GoRouter
/// and [BlocListener]s in the screens react to those states and push routes.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository repository,
    TokenStorage? tokenStorage,
    OnboardingService? onboardingService,
    CategoryRepository? categoryRepository,
  })  : _repository = repository,
        _tokenStorage = tokenStorage ?? TokenStorage(),
        _onboarding = onboardingService ?? OnboardingService(),
        _categoryRepository = categoryRepository ?? CategoryRepositoryImpl(),
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  final AuthRepository _repository;
  final TokenStorage _tokenStorage;
  final OnboardingService _onboarding;
  final CategoryRepository _categoryRepository;

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final hasTokens = await _tokenStorage.hasTokens();
    if (!hasTokens) {
      emit(const AuthUnauthenticated());
      return;
    }
    final needsOnboarding = !await _onboardingComplete();
    emit(AuthAuthenticated(needsOnboarding: needsOnboarding));
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _repository.login(email: event.email, password: event.password);
      final needsOnboarding = !await _onboardingComplete();
      emit(AuthAuthenticated(needsOnboarding: needsOnboarding));
    } on UnauthorizedFailure {
      emit(const AuthError(
          LocalizedMessage.code(FailureCode.authInvalidCredentials)));
    } on NetworkFailure {
      emit(const AuthError(
          LocalizedMessage.code(FailureCode.noInternetConnection)));
    } on Failure catch (f) {
      emit(AuthError(LocalizedMessage.raw(f.message)));
    } catch (e) {
      emit(AuthError(LocalizedMessage.raw(e.toString())));
    }
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _repository.register(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        currency: event.currency,
      );
      // New accounts always need onboarding regardless of the stored flag.
      emit(const AuthAuthenticated(needsOnboarding: true));
    } on ServerFailure catch (f) {
      if (f.statusCode == 409) {
        emit(const AuthError(
            LocalizedMessage.code(FailureCode.authEmailAlreadyRegistered)));
      } else {
        emit(AuthError(LocalizedMessage.raw(f.message)));
      }
    } on NetworkFailure {
      emit(const AuthError(
          LocalizedMessage.code(FailureCode.noInternetConnection)));
    } on Failure catch (f) {
      emit(AuthError(LocalizedMessage.raw(f.message)));
    } catch (e) {
      emit(AuthError(LocalizedMessage.raw(e.toString())));
    }
  }

  /// Checking real data is more reliable than the local onboarding flag,
  /// which can go stale. Falls back to the local flag when offline so
  /// already-onboarded users are not redirected to onboarding.
  Future<bool> _onboardingComplete() async {
    try {
      final categories = await _categoryRepository.listCategories();
      final done = categories.isNotEmpty;
      if (done) {
        // Keep local flags in sync so future offline launches are correct.
        if (!await _onboarding.hasCompleted()) await _onboarding.markComplete();
        if (!await _onboarding.hasCompletedAccounts()) {
          await _onboarding.markAccountsComplete();
        }
      }
      return done;
    } catch (_) {
      // Offline, trust the local flag.
      return await _onboarding.hasCompleted();
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken != null) {
      // Best-effort - repository swallows network errors and always clears.
      await _repository.logout(refreshToken: refreshToken);
    } else {
      await _tokenStorage.clearTokens();
    }
    emit(const AuthUnauthenticated());
  }
}
