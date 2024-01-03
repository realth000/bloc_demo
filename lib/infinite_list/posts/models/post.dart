part of 'models.dart';

/// Data model for post
@immutable
final class Post extends Equatable {
  const Post({required this.id, required this.title, required this.body});

  final int id;
  final String title;
  final String body;

  @override
  List<Object?> get props => [id, title, body];
}
