part of 'authentication_bloc.dart';

/// Auth event.
sealed class AuthEvent {
  const AuthEvent._();
}

final class _AuthStatusChanged extends AuthEvent {
  const _AuthStatusChanged(this.status) : super._();
  final AuthStatus status;
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested() : super._();
}
