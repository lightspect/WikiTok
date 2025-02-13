import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wikitok/article.dart';

class LikedArticleScreen extends StatefulWidget {
  final List<WikiArticle> likedArticles;
  final Function(int) onRemove;

  const LikedArticleScreen({
    super.key,
    required this.likedArticles,
    required this.onRemove,
  });

  @override
  State<LikedArticleScreen> createState() => _LikedArticleScreenState();
}

class _LikedArticleScreenState extends State<LikedArticleScreen> {
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
                                  "https://placehold.co/30x20.png",
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
