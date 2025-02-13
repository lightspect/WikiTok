import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wikitok/api.dart';
import 'package:wikitok/article.dart';
import 'package:wikitok/image_post.dart';
import 'package:wikitok/liked_article_screen.dart';
import 'package:wikitok/share_preferences.dart';

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
                builder: (context) => LikedArticleScreen(
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
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: "WikiTok",
                applicationVersion: "1.0.0",
                applicationIcon: Icon(Icons.info_outline),
                children: [
                  Text(
                      "WikiTok is a simple Wikipedia reader app that fetches articles from Wikipedia's API and displays them in a TikTok-like feed."),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: PageView.builder(
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
                          (article) => article.pageid == posts[index].pageid);
                    }
                    saveLikedArticles();
                  });
                },
              );
            }
          },
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
