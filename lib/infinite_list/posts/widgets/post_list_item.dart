part of 'widgets.dart';

/// Widget to show a [Post].
class PostListItem extends StatelessWidget {
  const PostListItem({required this.post, super.key});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      child: ListTile(
        leading: Text(
          '${post.id}',
          style: textTheme.bodySmall,
        ),
        title: Text(post.title),
        subtitle: Text(post.body, maxLines: 2),
        isThreeLine: true,
      ),
    );
  }
}
