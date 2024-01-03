import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User(this.id);

  const User.empty() : id = '-';

  final String id;

  @override
  List<Object?> get props => [id];

  @override
  String toString() {
    return '''User { id: $id }''';
  }
}
