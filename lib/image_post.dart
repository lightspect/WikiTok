import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wikitok/article.dart';

class ImagePost extends StatelessWidget {
  final WikiArticle postData;
  final int index;
  final VoidCallback onFavorite;

  const ImagePost({
    super.key,
    required this.postData,
    required this.index,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image of each article
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              fit: BoxFit.fitHeight,
              alignment: FractionalOffset.topCenter,
              image: NetworkImage(postData.thumbnail?.source ??
                  "https://placehold.co/600x400.png"),
            )),
          ),
          // Transparency overlay
          Container(
            color: Colors.black.withValues(alpha: 0.3),
          ),
          // Post information overlay
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _launchUrl,
                        child: Text(
                          postData.title ?? "Title",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        postData.extract ?? "Description",
                        style: const TextStyle(fontSize: 16),
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildSideBarItem(
                        Icons.read_more,
                        "Browse",
                        _launchUrl,
                      ),
                      const SizedBox(height: 20),
                      _buildSideBarItem(
                        postData.liked ? Icons.favorite : Icons.favorite_border,
                        "Favorite",
                        onFavorite,
                        color: postData.liked ? Colors.pink : Colors.white,
                      ),
                      const SizedBox(height: 20),
                      _buildSideBarItem(
                        Icons.share,
                        'Share',
                        () async => await Share.share(
                            postData.fullurl ?? "https://en.wikipedia.org",
                            subject: postData.title),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Double tap area for likes
          GestureDetector(
            onDoubleTap: () {
              onFavorite();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(postData.liked
                      ? 'Added to Favorites'
                      : 'Removed from Favorites'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSideBarItem(IconData icon, String label, Function onTap,
      {Color color = Colors.white}) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(postData.fullurl ?? "https://en.wikipedia.org");
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
