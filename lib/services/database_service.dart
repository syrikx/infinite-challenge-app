import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/magazine_article.dart';
import '../models/community_post.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'infinite_challenge.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        username TEXT UNIQUE NOT NULL,
        display_name TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'pending',
        created_at TEXT NOT NULL,
        last_login_at TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        profile_image_url TEXT,
        bio TEXT,
        reason TEXT
      )
    ''');

    // Magazine articles table
    await db.execute('''
      CREATE TABLE magazine_articles (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        excerpt TEXT NOT NULL,
        author_id TEXT NOT NULL,
        author_name TEXT NOT NULL,
        tags TEXT NOT NULL DEFAULT '[]',
        featured_image_url TEXT,
        image_urls TEXT NOT NULL DEFAULT '[]',
        status TEXT NOT NULL DEFAULT 'draft',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        published_at TEXT,
        view_count INTEGER NOT NULL DEFAULT 0,
        like_count INTEGER NOT NULL DEFAULT 0,
        category TEXT NOT NULL DEFAULT 'general',
        is_featured INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (author_id) REFERENCES users (id)
      )
    ''');

    // Community posts table
    await db.execute('''
      CREATE TABLE community_posts (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        author_id TEXT NOT NULL,
        author_name TEXT NOT NULL,
        tags TEXT NOT NULL DEFAULT '[]',
        image_urls TEXT NOT NULL DEFAULT '[]',
        type TEXT NOT NULL DEFAULT 'discussion',
        status TEXT NOT NULL DEFAULT 'active',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        view_count INTEGER NOT NULL DEFAULT 0,
        like_count INTEGER NOT NULL DEFAULT 0,
        reply_count INTEGER NOT NULL DEFAULT 0,
        is_pinned INTEGER NOT NULL DEFAULT 0,
        is_locked INTEGER NOT NULL DEFAULT 0,
        parent_id TEXT,
        FOREIGN KEY (author_id) REFERENCES users (id),
        FOREIGN KEY (parent_id) REFERENCES community_posts (id)
      )
    ''');

    // User likes table
    await db.execute('''
      CREATE TABLE user_likes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        content_type TEXT NOT NULL,
        content_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE(user_id, content_type, content_id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_articles_status ON magazine_articles(status)');
    await db.execute('CREATE INDEX idx_articles_category ON magazine_articles(category)');
    await db.execute('CREATE INDEX idx_posts_status ON community_posts(status)');
    await db.execute('CREATE INDEX idx_posts_type ON community_posts(type)');
    await db.execute('CREATE INDEX idx_posts_parent ON community_posts(parent_id)');
  }

  // User operations
  Future<String> insertUser(UserRegistration registration, String passwordHash) async {
    final db = await database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    await db.insert('users', {
      'id': id,
      'email': registration.email,
      'username': registration.username,
      'display_name': registration.displayName,
      'password_hash': passwordHash,
      'role': 'pending',
      'created_at': DateTime.now().toIso8601String(),
      'is_active': 1,
      'bio': registration.bio,
      'reason': registration.reason,
    });
    
    return id;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    
    if (results.isEmpty) return null;
    return User.fromJson(_convertDbUser(results.first));
  }

  Future<User?> getUserById(String id) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (results.isEmpty) return null;
    return User.fromJson(_convertDbUser(results.first));
  }

  Future<List<User>> getPendingUsers() async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at DESC',
    );
    
    return results.map((row) => User.fromJson(_convertDbUser(row))).toList();
  }

  Future<void> updateUserRole(String userId, UserRole role) async {
    final db = await database;
    await db.update(
      'users',
      {'role': role.name},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<String?> getUserPasswordHash(String email) async {
    final db = await database;
    final results = await db.query(
      'users',
      columns: ['password_hash'],
      where: 'email = ?',
      whereArgs: [email],
    );
    
    if (results.isEmpty) return null;
    return results.first['password_hash'] as String;
  }

  Map<String, dynamic> _convertDbUser(Map<String, Object?> dbUser) {
    return {
      'id': dbUser['id'],
      'email': dbUser['email'],
      'username': dbUser['username'],
      'display_name': dbUser['display_name'],
      'role': dbUser['role'],
      'created_at': dbUser['created_at'],
      'last_login_at': dbUser['last_login_at'],
      'is_active': dbUser['is_active'] == 1,
      'profile_image_url': dbUser['profile_image_url'],
      'bio': dbUser['bio'],
    };
  }

  // Magazine article operations
  Future<String> insertArticle(MagazineArticle article) async {
    final db = await database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    await db.insert('magazine_articles', {
      'id': id,
      'title': article.title,
      'content': article.content,
      'excerpt': article.excerpt,
      'author_id': article.authorId,
      'author_name': article.authorName,
      'tags': jsonEncode(article.tags),
      'featured_image_url': article.featuredImageUrl,
      'image_urls': jsonEncode(article.imageUrls),
      'status': article.status.name,
      'created_at': article.createdAt.toIso8601String(),
      'updated_at': article.updatedAt.toIso8601String(),
      'published_at': article.publishedAt?.toIso8601String(),
      'view_count': article.viewCount,
      'like_count': article.likeCount,
      'category': article.category.name,
      'is_featured': article.isFeatured ? 1 : 0,
    });
    
    return id;
  }

  Future<List<MagazineArticle>> getPublishedArticles({int limit = 20, int offset = 0}) async {
    final db = await database;
    final results = await db.query(
      'magazine_articles',
      where: 'status = ?',
      whereArgs: ['published'],
      orderBy: 'published_at DESC',
      limit: limit,
      offset: offset,
    );
    
    return results.map((row) => MagazineArticle.fromJson(_convertDbArticle(row))).toList();
  }

  Future<MagazineArticle?> getArticleById(String id) async {
    final db = await database;
    final results = await db.query(
      'magazine_articles',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (results.isEmpty) return null;
    return MagazineArticle.fromJson(_convertDbArticle(results.first));
  }

  Map<String, dynamic> _convertDbArticle(Map<String, Object?> dbArticle) {
    return {
      'id': dbArticle['id'],
      'title': dbArticle['title'],
      'content': dbArticle['content'],
      'excerpt': dbArticle['excerpt'],
      'author_id': dbArticle['author_id'],
      'author_name': dbArticle['author_name'],
      'tags': jsonDecode(dbArticle['tags'] as String),
      'featured_image_url': dbArticle['featured_image_url'],
      'image_urls': jsonDecode(dbArticle['image_urls'] as String),
      'status': dbArticle['status'],
      'created_at': dbArticle['created_at'],
      'updated_at': dbArticle['updated_at'],
      'published_at': dbArticle['published_at'],
      'view_count': dbArticle['view_count'],
      'like_count': dbArticle['like_count'],
      'category': dbArticle['category'],
      'is_featured': dbArticle['is_featured'] == 1,
    };
  }

  // Community post operations
  Future<String> insertPost(CommunityPost post) async {
    final db = await database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    await db.insert('community_posts', {
      'id': id,
      'title': post.title,
      'content': post.content,
      'author_id': post.authorId,
      'author_name': post.authorName,
      'tags': jsonEncode(post.tags),
      'image_urls': jsonEncode(post.imageUrls),
      'type': post.type.name,
      'status': post.status.name,
      'created_at': post.createdAt.toIso8601String(),
      'updated_at': post.updatedAt.toIso8601String(),
      'view_count': post.viewCount,
      'like_count': post.likeCount,
      'reply_count': post.replyCount,
      'is_pinned': post.isPinned ? 1 : 0,
      'is_locked': post.isLocked ? 1 : 0,
      'parent_id': post.parentId,
    });
    
    return id;
  }

  Future<List<CommunityPost>> getActivePosts({int limit = 20, int offset = 0}) async {
    final db = await database;
    final results = await db.query(
      'community_posts',
      where: 'status = ? AND parent_id IS NULL',
      whereArgs: ['active'],
      orderBy: 'is_pinned DESC, created_at DESC',
      limit: limit,
      offset: offset,
    );
    
    return results.map((row) => CommunityPost.fromJson(_convertDbPost(row))).toList();
  }

  Future<CommunityPost?> getPostById(String id) async {
    final db = await database;
    final results = await db.query(
      'community_posts',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (results.isEmpty) return null;
    return CommunityPost.fromJson(_convertDbPost(results.first));
  }

  Future<List<CommunityPost>> getPostReplies(String postId) async {
    final db = await database;
    final results = await db.query(
      'community_posts',
      where: 'parent_id = ? AND status = ?',
      whereArgs: [postId, 'active'],
      orderBy: 'created_at ASC',
    );
    
    return results.map((row) => CommunityPost.fromJson(_convertDbPost(row))).toList();
  }

  Map<String, dynamic> _convertDbPost(Map<String, Object?> dbPost) {
    return {
      'id': dbPost['id'],
      'title': dbPost['title'],
      'content': dbPost['content'],
      'author_id': dbPost['author_id'],
      'author_name': dbPost['author_name'],
      'tags': jsonDecode(dbPost['tags'] as String),
      'image_urls': jsonDecode(dbPost['image_urls'] as String),
      'type': dbPost['type'],
      'status': dbPost['status'],
      'created_at': dbPost['created_at'],
      'updated_at': dbPost['updated_at'],
      'view_count': dbPost['view_count'],
      'like_count': dbPost['like_count'],
      'reply_count': dbPost['reply_count'],
      'is_pinned': dbPost['is_pinned'] == 1,
      'is_locked': dbPost['is_locked'] == 1,
      'parent_id': dbPost['parent_id'],
    };
  }
}