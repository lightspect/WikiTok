import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wikitok/api.dart';
import 'package:wikitok/article.dart';
import 'package:wikitok/share_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WikiTok',
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
  List<WikiArticle> likedArticles = [];
  SharedPreferencesManager sharedPreferencesManager =
      SharedPreferencesManager();

  @override
  void initState() {
    getArticles();
    sharedPreferencesManager.init();
    loadLikedArticles();
    super.initState();
  }

  Future<void> loadLikedArticles() async {
    List<String>? likedArticlesJson =
        await sharedPreferencesManager.getStringList("likedArticles");
    if (likedArticlesJson != null) {
      likedArticles = likedArticlesJson
          .map((e) => WikiArticle.fromJson(jsonDecode(e)))
          .toList();
    }
  }

  Future<void> saveLikedArticles() async {
    List<String> likedArticlesJson =
        likedArticles.map((e) => jsonEncode(e.toJson())).toList();
    await sharedPreferencesManager.setStringList(
        "likedArticles", likedArticlesJson);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('WikiTok'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => LikedArticleDialog(
                  likedArticles: likedArticles,
                  onRemove: (index) {
                    final removedArticle = likedArticles.removeAt(index);
                    setState(() {
                      posts
                          .firstWhere((article) =>
                              article.pageid == removedArticle.pageid)
                          .liked = false;
                    });
                    saveLikedArticles();
                  },
                ),
              ));
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Stack(
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
                    onFavorite: () async {
                      setState(() {
                        posts[index].liked = !posts[index].liked;
                        if (posts[index].liked) {
                          likedArticles.add(posts[index]);
                        } else {
                          likedArticles.removeWhere(
                              (article) => article.title == posts[index].title);
                        }
                        saveLikedArticles();
                      });
                    },
                  );
                }
              },
            ),
            // Overlay UI elements
          ],
        ),
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
                      GestureDetector(
                        onTap: _launchUrl,
                        child: Text(
                          postData.title ?? "Title",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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

class LikedArticleDialog extends StatefulWidget {
  final List<WikiArticle> likedArticles;
  final Function(int) onRemove;

  const LikedArticleDialog({
    super.key,
    required this.likedArticles,
    required this.onRemove,
  });

  @override
  State<LikedArticleDialog> createState() => _LikedArticleDialogState();
}

class _LikedArticleDialogState extends State<LikedArticleDialog> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark theme background
      appBar: AppBar(
        title: Text("Liked Articles"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search liked articles...",
                prefixIcon: Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: widget.likedArticles.isEmpty
                ? Center(
                    child: Text("No liked articles",
                        style: TextStyle(color: Colors.white54)))
                : ListView.builder(
                    itemCount: widget.likedArticles.length,
                    itemBuilder: (context, index) {
                      final article = widget.likedArticles[index];
                      if (!article.title!.toLowerCase().contains(searchQuery)) {
                        return SizedBox.shrink();
                      }
                      return GestureDetector(
                        onTap: () => launchUrl(Uri.parse(
                            article.fullurl ?? "https://en.wikipedia.org")),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              article.thumbnail?.source ??
                                  "https://placehold.co/300x200.png",
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(article.title ?? "Title",
                              style: TextStyle(color: Colors.white)),
                          subtitle: Text(article.extract ?? "Description",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white70)),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              widget.onRemove(index);
                              setState(() {});
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
