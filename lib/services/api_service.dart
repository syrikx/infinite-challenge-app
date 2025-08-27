import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/magazine_article.dart';
import '../models/community_post.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  static const String _tokenKey = 'auth_token';
  
  String? _cachedToken;

  // Get stored token
  Future<String?> _getToken() async {
    if (_cachedToken != null) return _cachedToken;
    
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_tokenKey);
    return _cachedToken;
  }

  // Store token
  Future<void> _storeToken(String token) async {
    _cachedToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Remove token
  Future<void> _removeToken() async {
    _cachedToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Get headers with authorization
  Future<Map<String, String>> _getHeaders([bool includeAuth = true]) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (includeAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: body['message'] ?? body['error'] ?? 'Unknown error',
        details: body,
      );
    }
  }

  // Auth endpoints
  Future<AuthResponse> register(UserRegistration registration) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: await _getHeaders(false),
      body: jsonEncode(registration.toJson()),
    );

    final data = _handleResponse(response);
    return AuthResponse.fromJson(data);
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await _getHeaders(false),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = _handleResponse(response);
    
    // Store token if login successful
    if (data['token'] != null) {
      await _storeToken(data['token']);
    }

    return AuthResponse.fromJson(data);
  }

  Future<User> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: await _getHeaders(),
    );

    final data = _handleResponse(response);
    return User.fromJson(data['user']);
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: await _getHeaders(),
      );
    } finally {
      await _removeToken();
    }
  }

  // User management endpoints
  Future<List<User>> getPendingUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/pending'),
      headers: await _getHeaders(),
    );

    final data = _handleResponse(response);
    return (data['users'] as List)
        .map((user) => User.fromJson(user))
        .toList();
  }

  Future<void> approveUser(String userId, [String role = 'member']) async {
    await http.put(
      Uri.parse('$baseUrl/users/$userId/approve'),
      headers: await _getHeaders(),
      body: jsonEncode({'role': role}),
    );
  }

  Future<void> rejectUser(String userId) async {
    await http.delete(
      Uri.parse('$baseUrl/users/$userId/reject'),
      headers: await _getHeaders(),
    );
  }

  Future<void> changeUserRole(String userId, String role) async {
    await http.put(
      Uri.parse('$baseUrl/users/$userId/role'),
      headers: await _getHeaders(),
      body: jsonEncode({'role': role}),
    );
  }

  // Magazine endpoints
  Future<MagazineResponse> getMagazines({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    if (category != null) query['category'] = category;
    if (search != null) query['search'] = search;

    final uri = Uri.parse('$baseUrl/magazines').replace(queryParameters: query);
    final response = await http.get(uri, headers: await _getHeaders(false));

    final data = _handleResponse(response);
    return MagazineResponse.fromJson(data);
  }

  Future<MagazineArticle> getMagazineById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/magazines/$id'),
      headers: await _getHeaders(false),
    );

    final data = _handleResponse(response);
    return MagazineArticle.fromJson(data['article']);
  }

  Future<MagazineArticle> createMagazine(MagazineArticle article) async {
    final response = await http.post(
      Uri.parse('$baseUrl/magazines'),
      headers: await _getHeaders(),
      body: jsonEncode(article.toJson()),
    );

    final data = _handleResponse(response);
    return MagazineArticle.fromJson(data['article']);
  }

  // Community endpoints
  Future<CommunityResponse> getCommunityPosts({
    int page = 1,
    int limit = 20,
    String? type,
    String? search,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    if (type != null) query['type'] = type;
    if (search != null) query['search'] = search;

    final uri = Uri.parse('$baseUrl/community').replace(queryParameters: query);
    final response = await http.get(uri, headers: await _getHeaders(false));

    final data = _handleResponse(response);
    return CommunityResponse.fromJson(data);
  }

  Future<PostWithReplies> getCommunityPostById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/community/$id'),
      headers: await _getHeaders(false),
    );

    final data = _handleResponse(response);
    return PostWithReplies.fromJson(data);
  }

  Future<CommunityPost> createCommunityPost(CommunityPost post) async {
    final response = await http.post(
      Uri.parse('$baseUrl/community'),
      headers: await _getHeaders(),
      body: jsonEncode(post.toJson()),
    );

    final data = _handleResponse(response);
    return CommunityPost.fromJson(data['post']);
  }
}

// Response classes
class AuthResponse {
  final String message;
  final String? token;
  final User? user;

  AuthResponse({
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'],
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class MagazineResponse {
  final List<MagazineArticle> articles;
  final Pagination pagination;

  MagazineResponse({
    required this.articles,
    required this.pagination,
  });

  factory MagazineResponse.fromJson(Map<String, dynamic> json) {
    return MagazineResponse(
      articles: (json['articles'] as List)
          .map((article) => MagazineArticle.fromJson(article))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

class CommunityResponse {
  final List<CommunityPost> posts;
  final Pagination pagination;

  CommunityResponse({
    required this.posts,
    required this.pagination,
  });

  factory CommunityResponse.fromJson(Map<String, dynamic> json) {
    return CommunityResponse(
      posts: (json['posts'] as List)
          .map((post) => CommunityPost.fromJson(post))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

class PostWithReplies {
  final CommunityPost post;
  final List<CommunityPost> replies;

  PostWithReplies({
    required this.post,
    required this.replies,
  });

  factory PostWithReplies.fromJson(Map<String, dynamic> json) {
    return PostWithReplies(
      post: CommunityPost.fromJson(json['post']),
      replies: (json['replies'] as List)
          .map((reply) => CommunityPost.fromJson(reply))
          .toList(),
    );
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int total;
  final bool hasNext;
  final bool hasPrev;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.total,
    required this.hasNext,
    required this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      total: json['totalArticles'] ?? json['totalPosts'] ?? json['total'],
      hasNext: json['hasNext'],
      hasPrev: json['hasPrev'],
    );
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? details;

  ApiException({
    required this.statusCode,
    required this.message,
    this.details,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }
}