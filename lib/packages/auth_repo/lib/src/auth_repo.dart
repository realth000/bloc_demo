import 'dart:async';

sealed class AuthStatus {
  const AuthStatus._();
}

final class AuthUnknown extends AuthStatus {
  const AuthUnknown() : super._();
}

final class AuthAuthed extends AuthStatus {
  const AuthAuthed() : super._();
}

final class AuthUnauthed extends AuthStatus {
  const AuthUnauthed() : super._();
}

class AuthRepo {
  final _controller = StreamController<AuthStatus>();

  /// Expose this stream to notify user signs in or out.
  Stream<AuthStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield AuthUnauthed();
    yield* _controller.stream;
  }

  Future<void> logIn({
    required String username,
    required String password,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: 300),
      () => _controller.add(AuthAuthed()),
    );
  }

  Future<void> logOut() async {
    await Future.delayed(
      const Duration(milliseconds: 300),
      () => _controller.add(AuthUnauthed()),
    );
  }

  void dispose() {
    _controller.close();
  }
}
