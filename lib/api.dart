import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:wikitok/article.dart';

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<Map<String, dynamic>> getRequest(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  Future<List<WikiArticle>> getArticles() async {
    final response = await getRequest(
        '/api.php?action=query&format=json&prop=extracts%7Cpageimages%7Cinfo&generator=random&formatversion=2&exsentences=5&exlimit=max&exintro=1&explaintext=1&pithumbsize=400&inprop=url&grnnamespace=0&grnlimit=20');
    final List<dynamic> articles = response['query']['search'];
    return articles.map((json) => WikiArticle.fromJson(json)).toList();
  }
}
