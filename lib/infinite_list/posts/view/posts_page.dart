part of 'view.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Build list every time when PostBloc changes.
    return BlocProvider(
      create: (_) => PostBloc(httpClient: http.Client())..add(PostFetched()),
      child: const PostsList(),
    );
  }
}
