part of 'post_bloc.dart';

/// Status of a post.
///
/// Use sealed class to enhance error handling by carrying extra messages.
///
/// This is status or result of an [PostEvent].
sealed class PostStatus {
  const PostStatus._();
}

/// Initial state.
final class PostInitial extends PostStatus {
  const PostInitial() : super._();
}

/// Failed to fetch posts.
final class PostFailure extends PostStatus {
  const PostFailure(this.message) : super._();

  final String message;
}

final class PostSuccess extends PostStatus {
  const PostSuccess() : super._();
}

final class PostState extends Equatable {
  const PostState({
    required this.status,
    required this.posts,
    required this.hasReachedMax,
  });

  final PostStatus status;
  final List<Post> posts;
  final bool hasReachedMax;

  PostState copyWith({
    PostStatus? status,
    List<Post>? posts,
    bool? hasReachedMax,
  }) {
    return PostState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() {
    return '''PostState { status: $status, hasReachedMax: $hasReachedMax, posts: $posts }''';
  }

  @override
  // TODO: implement props
  List<Object?> get props => [status, posts, hasReachedMax];
}
