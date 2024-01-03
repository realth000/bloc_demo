import 'package:user_repo/src/models/user.dart';
import 'package:uuid/uuid.dart';

const Uuid _uuid = Uuid();

class UserRepo {
  User? _user;

  Future<User?> getUser() async {
    if (_user != null) {
      return _user;
    }

    return Future.delayed(
      const Duration(milliseconds: 300),
      () => _user = User(_uuid.v4()),
    );
  }
}
