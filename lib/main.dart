import 'package:flutter/material.dart';

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
  int _currentPage = 0;

  // Sample image data - replace with your actual image data
  final List<PostData> posts = [
    PostData(
      username: '@nature_lover',
      description: 'Beautiful sunset at the beach 🌅 #nature #sunset',
      likes: '1.2K',
      comments: '234',
    ),
    PostData(
      username: '@traveler',
      description: 'Exploring the mountains ⛰️ #adventure #travel',
      likes: '3.4K',
      comments: '456',
    ),
    PostData(
      username: '@foodie',
      description: 'Delicious homemade pasta 🍝 #food #cooking',
      likes: '2.8K',
      comments: '345',
    ),
  ];

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
            scrollDirection: Axis.vertical,
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return ImagePost(
                postData: posts[index % posts.length],
                index: index,
              );
            },
          ),
          // Overlay UI elements
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildSideBarItem(
                        Icons.favorite,
                        posts[_currentPage % posts.length].likes,
                      ),
                      const SizedBox(height: 20),
                      _buildSideBarItem(
                        Icons.comment,
                        posts[_currentPage % posts.length].comments,
                      ),
                      const SizedBox(height: 20),
                      _buildSideBarItem(Icons.share, 'Share'),
                    ],
                  ),
                ),
              ],
            ),
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
  final PostData postData;
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
          // Image placeholder with different colors for each post
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  HSLColor.fromAHSL(
                    1.0,
                    (index * 45.0) % 360.0,
                    0.8,
                    0.5,
                  ).toColor(),
                  HSLColor.fromAHSL(
                    1.0,
                    ((index * 45.0) + 45.0) % 360.0,
                    0.8,
                    0.5,
                  ).toColor(),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.image,
                size: 100,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
          // Post information overlay
          Positioned(
            bottom: 80,
            left: 8,
            right: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  postData.username,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  postData.description,
                  style: const TextStyle(fontSize: 14),
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
}