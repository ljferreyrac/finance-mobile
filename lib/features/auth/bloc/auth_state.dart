import 'package:equatable/equatable.dart';

/// States emitted by [AuthBloc].
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

/// The user has valid tokens in secure storage.
///
/// [needsOnboarding] is true when the user has never completed the onboarding
/// flow. The GoRouter redirect uses this flag to send new users to /onboarding
/// and returning users directly to /transactions.
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({this.needsOnboarding = false});

  final bool needsOnboarding;

  @override
  List<Object?> get props => [needsOnboarding];
}

/// No valid tokens are present; the GoRouter redirect forwards to /login.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// [message] is a user-facing Spanish string suitable for a SnackBar.
class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
