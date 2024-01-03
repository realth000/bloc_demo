part of 'authentication_bloc.dart';

class AuthState extends Equatable {
  const AuthState._({
    this.status = const AuthUnknown(),
    this.user = const User.empty(),
  });

  const AuthState.unknown() : this._();

  const AuthState.authed(User user)
      : this._(status: const AuthAuthed(), user: user);

  const AuthState.unauthed() : this._(status: const AuthUnauthed());

  final AuthStatus status;
  final User user;

  @override
  List<Object?> get props => [status, user];
}
