import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:bloc_demo/infinite_list/posts/models/models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:stream_transform/stream_transform.dart';

part 'post_event.dart';
part 'post_state.dart';

const _postLimit = 20;
const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

/// Take in [PostEvent] and output [PostState].
class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({required this.httpClient})
      : super(
          const PostState(
            status: PostInitial(),
            posts: [],
            hasReachedMax: false,
          ),
        ) {
    on<PostFetched>(
      _onPostFetched,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  final http.Client httpClient;

  Future<void> _onPostFetched(
      PostFetched event, Emitter<PostState> emit) async {
    if (state.hasReachedMax) {
      return;
    }
    try {
      if (state.status is PostInitial) {
        final posts = await _fetchPosts();
        return emit(state.copyWith(
          status: const PostSuccess(),
          posts: posts,
          hasReachedMax: false,
        ));
      }

      final posts = await _fetchPosts(state.posts.length);
      emit(posts.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
              status: const PostSuccess(),
              posts: List.of(state.posts)..addAll(posts),
              hasReachedMax: false,
            ));
    } catch (e, _) {
      emit(state.copyWith(status: PostFailure('$e')));
    }
  }

  Future<List<Post>> _fetchPosts([int startIndex = 0]) async {
    final resp = await httpClient.get(
        Uri.https('jsonplaceholder.typicode.com', '/posts', <String, String>{
      '_start': '$startIndex',
      '_limit': '$_postLimit',
    }));
    if (resp.statusCode != HttpStatus.ok) {
      throw Exception('error fetching posts: ${resp.statusCode}');
    }

    final body = jsonDecode(resp.body) as List;
    return body.map((dynamic json) {
      final map = json as Map<String, dynamic>;
      return Post(
        id: map['id'] as int,
        title: map['title'] as String,
        body: map['body'] as String,
      );
    }).toList();
  }
}
