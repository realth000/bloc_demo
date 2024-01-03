part of 'post_bloc.dart';

sealed class PostEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

@immutable
final class PostFetched extends PostEvent {}
