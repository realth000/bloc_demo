part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent._();

  @override
  List<Object?> get props => [];
}

final class LoginUsernameChanged extends LoginEvent {
  const LoginUsernameChanged(this.username) : super._();

  final String username;

  @override
  List<Object?> get props => [username];
}

final class LoginPasswordChanged extends LoginEvent {
  const LoginPasswordChanged(this.password) : super._();

  final String password;

  @override
  List<Object?> get props => [password];
}

final class LoginSubmitted extends LoginEvent {
  const LoginSubmitted() : super._();
}
