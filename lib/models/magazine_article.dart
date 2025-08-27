class MagazineArticle {
  final String id;
  final String title;
  final String content;
  final String excerpt;
  final String authorId;
  final String authorName;
  final List<String> tags;
  final String? featuredImageUrl;
  final List<String> imageUrls;
  final ArticleStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  final int viewCount;
  final int likeCount;
  final ArticleCategory category;
  final bool isFeatured;

  MagazineArticle({
    required this.id,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.authorId,
    required this.authorName,
    this.tags = const [],
    this.featuredImageUrl,
    this.imageUrls = const [],
    this.status = ArticleStatus.draft,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    this.viewCount = 0,
    this.likeCount = 0,
    this.category = ArticleCategory.general,
    this.isFeatured = false,
  });

  factory MagazineArticle.fromJson(Map<String, dynamic> json) {
    return MagazineArticle(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      excerpt: json['excerpt'],
      authorId: json['author_id'],
      authorName: json['author_name'],
      tags: List<String>.from(json['tags'] ?? []),
      featuredImageUrl: json['featured_image_url'],
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      status: ArticleStatus.values.byName(json['status']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      publishedAt: json['published_at'] != null 
        ? DateTime.parse(json['published_at']) 
        : null,
      viewCount: json['view_count'] ?? 0,
      likeCount: json['like_count'] ?? 0,
      category: ArticleCategory.values.byName(json['category']),
      isFeatured: json['is_featured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'excerpt': excerpt,
      'author_id': authorId,
      'author_name': authorName,
      'tags': tags,
      'featured_image_url': featuredImageUrl,
      'image_urls': imageUrls,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'published_at': publishedAt?.toIso8601String(),
      'view_count': viewCount,
      'like_count': likeCount,
      'category': category.name,
      'is_featured': isFeatured,
    };
  }

  MagazineArticle copyWith({
    String? id,
    String? title,
    String? content,
    String? excerpt,
    String? authorId,
    String? authorName,
    List<String>? tags,
    String? featuredImageUrl,
    List<String>? imageUrls,
    ArticleStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
    int? viewCount,
    int? likeCount,
    ArticleCategory? category,
    bool? isFeatured,
  }) {
    return MagazineArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      excerpt: excerpt ?? this.excerpt,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      tags: tags ?? this.tags,
      featuredImageUrl: featuredImageUrl ?? this.featuredImageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      category: category ?? this.category,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}

enum ArticleStatus {
  draft,      // 초안
  submitted,  // 제출됨 (검토 대기)
  published,  // 게시됨
  archived,   // 보관됨
}

enum ArticleCategory {
  general,    // 일반
  calculus,   // 미적분학
  algebra,    // 대수학
  geometry,   // 기하학
  statistics, // 통계학
  research,   // 연구
  news,       // 뉴스
  tutorial,   // 튜토리얼
}