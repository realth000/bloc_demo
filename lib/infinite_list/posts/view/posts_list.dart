part of 'view.dart';

/// Have scroll state so becomes a stateful widget.
class PostsList extends StatefulWidget {
  const PostsList({super.key});

  @override
  State<PostsList> createState() => _PostsListState();
}

class _PostsListState extends State<PostsList> {
  final _scrollController = ScrollController();

  /// Flag indicate reached bottom of [ListView] or not.
  bool get _isBottom {
    if (!_scrollController.hasClients) {
      return false;
    }
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  /// Fetch more posts on when scroll at bottom.
  void _onScroll() {
    if (_isBottom) {
      context.read<PostBloc>().add(PostFetched());
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Build widgets from [PostBloc] and [PostState].
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        switch (state.status) {
          /// Show the error.
          case PostFailure():
            return Center(
              child: Text(
                  'failed to fetch posts ${(state.status as PostFailure).message}'),
            );
          case PostSuccess():
            if (state.posts.isEmpty) {
              return const Center(child: Text('No More Posts'));
            }
            return ListView.builder(
              itemCount: state.hasReachedMax
                  ? state.posts.length
                  : state.posts.length + 1,
              itemBuilder: (context, index) {
                return index >= state.posts.length
                    ? const BottomLoader()
                    : PostListItem(post: state.posts[index]);
              },
              controller: _scrollController,
            );

          case PostInitial():
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
