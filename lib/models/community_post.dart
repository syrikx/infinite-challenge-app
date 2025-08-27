class CommunityPost {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final List<String> tags;
  final List<String> imageUrls;
  final PostType type;
  final PostStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int viewCount;
  final int likeCount;
  final int replyCount;
  final bool isPinned;
  final bool isLocked;
  final String? parentId; // for replies

  CommunityPost({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.tags = const [],
    this.imageUrls = const [],
    this.type = PostType.discussion,
    this.status = PostStatus.active,
    required this.createdAt,
    required this.updatedAt,
    this.viewCount = 0,
    this.likeCount = 0,
    this.replyCount = 0,
    this.isPinned = false,
    this.isLocked = false,
    this.parentId,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      authorId: json['author_id'],
      authorName: json['author_name'],
      tags: List<String>.from(json['tags'] ?? []),
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      type: PostType.values.byName(json['type']),
      status: PostStatus.values.byName(json['status']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      viewCount: json['view_count'] ?? 0,
      likeCount: json['like_count'] ?? 0,
      replyCount: json['reply_count'] ?? 0,
      isPinned: json['is_pinned'] ?? false,
      isLocked: json['is_locked'] ?? false,
      parentId: json['parent_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author_id': authorId,
      'author_name': authorName,
      'tags': tags,
      'image_urls': imageUrls,
      'type': type.name,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'view_count': viewCount,
      'like_count': likeCount,
      'reply_count': replyCount,
      'is_pinned': isPinned,
      'is_locked': isLocked,
      'parent_id': parentId,
    };
  }

  CommunityPost copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    List<String>? tags,
    List<String>? imageUrls,
    PostType? type,
    PostStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? viewCount,
    int? likeCount,
    int? replyCount,
    bool? isPinned,
    bool? isLocked,
    String? parentId,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      tags: tags ?? this.tags,
      imageUrls: imageUrls ?? this.imageUrls,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      replyCount: replyCount ?? this.replyCount,
      isPinned: isPinned ?? this.isPinned,
      isLocked: isLocked ?? this.isLocked,
      parentId: parentId ?? this.parentId,
    );
  }

  bool get isReply => parentId != null;
}

enum PostType {
  discussion, // 토론
  question,   // 질문
  news,       // 소식
  help,       // 도움
  showcase,   // 작품 공유
}

enum PostStatus {
  active,     // 활성
  hidden,     // 숨김
  deleted,    // 삭제됨
  reported,   // 신고됨
}