import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lab7/postApp/pages/post_create.dart';
import 'dart:convert';

import '../components/post_card.dart' show PostCard;

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}


class _PostsPageState extends State<PostsPage> {
  List<dynamic> posts = [];
  bool isLoading = false;
  bool hasFailed = false;

  Future<void> fetchPosts() async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse('https://jsonplaceholder.typicode.com/posts');

    try {
      var response = await http.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (kDebugMode) {
          print('Data received: $jsonResponse');
        }
        setState(() {
          posts = jsonResponse;
          hasFailed = false;
          isLoading = false;
        });
      } else {
        if (kDebugMode) {
          print('Request failed with status: ${response.statusCode}.');
        }
        setState(() {
          hasFailed = true;
          isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during HTTP request: $e');
      }
      setState(() {
        hasFailed = true;
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Posts")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PostCreatePage()));
        },
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (hasFailed)
            Column(
              children: [
                Text(
                  'Failed to load data. Please try again.',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: fetchPosts,
                  icon: Icon(Icons.restart_alt_outlined, color: theme.primaryColor),
                  label: const Text('Retry'),
                  style: TextButton.styleFrom(
                    backgroundColor: theme.dividerColor,
                    foregroundColor: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
                : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return PostCard(
                  title: post['title'],
                  body: post['body'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}