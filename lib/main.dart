import 'package:flutter/material.dart';
import 'package:wikitok/api.dart';
import 'package:wikitok/article.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Feed',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const FeedScreen(),
    );
  }
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PageController _pageController = PageController();

  // Sample image data - replace with your actual image data
  List<WikiArticle> posts = [];
  List<WikiArticle> bufferPosts = [];

  @override
  void initState() {
    getArticles();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          PageView.builder(
            allowImplicitScrolling: true,
            scrollDirection: Axis.vertical,
            controller: _pageController,
            onPageChanged: (index) async {
              if (index == posts.length - 5) {
                await getMoreArticles();
              }
            },
            itemBuilder: (context, index) {
              if (posts.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return ImagePost(
                  postData: posts[index],
                  index: index,
                );
              }
            },
          ),
          // Overlay UI elements
        ],
      ),
    );
  }

  Future<void> getArticles({bool forBuffer = false}) async {
    ApiService apiService = ApiService('en.wikipedia.org');
    List<WikiArticle> getPosts = await apiService.getArticles();
    final filteredPosts = getPosts
        .where(
            (post) => post.thumbnail != null && post.thumbnail?.source != null)
        .toList();
    if (forBuffer) {
      bufferPosts = filteredPosts;
    } else {
      posts.addAll(filteredPosts);
      getArticles(forBuffer: true);
    }
    setState(() {});
    _preloadImages();
  }

  Future<void> getMoreArticles() async {
    posts.addAll(bufferPosts);
    getArticles(forBuffer: true);
  }

  void _preloadImages() {
    for (int i = 0; i < posts.length; i++) {
      precacheImage(
          NetworkImage(
              posts[i].thumbnail?.source ?? "https://placehold.co/600x400.png"),
          context);
    }
  }
}

class PostData {
  final String username;
  final String description;
  final String likes;
  final String comments;

  PostData({
    required this.username,
    required this.description,
    required this.likes,
    required this.comments,
  });
}

class ImagePost extends StatelessWidget {
  final WikiArticle postData;
  final int index;

  const ImagePost({
    super.key,
    required this.postData,
    required this.index,
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
            color: Colors.black.withValues(alpha: 0.5),
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
                      Text(
                        postData.title ?? "Title",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        postData.extract ?? "Description",
                        style: const TextStyle(fontSize: 14),
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
                        Icons.favorite,
                        "Favorite",
                      ),
                      const SizedBox(height: 20),
                      _buildSideBarItem(Icons.share, 'Share'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Double tap area for likes
          GestureDetector(
            onDoubleTap: () {
              // Add like functionality here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Double tapped! Add like functionality here.'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSideBarItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
