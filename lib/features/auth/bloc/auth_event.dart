import 'package:equatable/equatable.dart';

/// Events dispatched to [AuthBloc].
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Checks whether valid tokens already exist in secure storage.
///
/// Dispatched automatically when [AuthBloc] is created so the app can
/// redirect to the correct initial route without showing a flash of the
/// login screen.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class LoginSubmitted extends AuthEvent {
  const LoginSubmitted({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class RegisterSubmitted extends AuthEvent {
  const RegisterSubmitted({
    required this.email,
    required this.password,
    required this.fullName,
    this.currency = 'PEN',
  });

  final String email;
  final String password;
  final String fullName;

  /// ISO 4217 currency code. Defaults to Peruvian Sol.
  final String currency;

  @override
  List<Object?> get props => [email, password, fullName, currency];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
