import 'dart:async';

import 'package:auth_repo/auth_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repo/user_repo.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

/// [AuthBloc] depends on [AuthRepo] and [UserRepo].
/// Transform [AuthEvent] into [AuthState].
/// In [AuthState] carries [AuthStatus] with additional user info [User].
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepo authRepo, required UserRepo userRepo})
      : _authRepo = authRepo,
        _userRepo = userRepo,
        super(const AuthState.unknown()) {
    on<_AuthStatusChanged>(_onAuthStatusChanged);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    _authStatusSub =
        _authRepo.status.listen((status) => add(_AuthStatusChanged(status)));
  }

  final AuthRepo _authRepo;
  final UserRepo _userRepo;

  /// Use to listen [AuthStatus] changes in [_authRepo].
  late StreamSubscription<AuthStatus> _authStatusSub;

  @override
  Future<void> close() async {
    _authStatusSub.cancel();
    super.close();
  }

  Future<void> _onAuthStatusChanged(
      _AuthStatusChanged event, Emitter<AuthState> emit) async {
    switch (event.status) {
      case AuthUnauthed():
        return emit(const AuthState.unauthed());
      case AuthAuthed():
        final user = await _getUser();
        if (user == null) {
          return emit(const AuthState.unauthed());
        }
        return emit(AuthState.authed(user));
      case AuthUnknown():
        return emit(const AuthState.unknown());
    }
  }

  void _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) {
    _authRepo.logOut();
  }

  Future<User?> _getUser() async {
    try {
      final user = await _userRepo.getUser();
      return user;
    } catch (_) {
      return null;
    }
  }
}
