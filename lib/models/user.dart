class User {
  final String id;
  final String email;
  final String username;
  final String displayName;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final String? profileImageUrl;
  final String? bio;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    required this.role,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
    this.profileImageUrl,
    this.bio,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      displayName: json['display_name'],
      role: UserRole.values.byName(json['role']),
      createdAt: DateTime.parse(json['created_at']),
      lastLoginAt: json['last_login_at'] != null 
        ? DateTime.parse(json['last_login_at']) 
        : null,
      isActive: json['is_active'] ?? true,
      profileImageUrl: json['profile_image_url'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'display_name': displayName,
      'role': role.name,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'is_active': isActive,
      'profile_image_url': profileImageUrl,
      'bio': bio,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
    String? profileImageUrl,
    String? bio,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
    );
  }

  bool get canCreatePosts => role == UserRole.admin || role == UserRole.editor || role == UserRole.member;
  bool get canModerate => role == UserRole.admin || role == UserRole.moderator;
  bool get isAdmin => role == UserRole.admin;
}

enum UserRole {
  guest,
  pending,    // 가입 신청 중
  member,     // 일반 회원
  editor,     // 에디터 권한 (매거진 작성 가능)
  moderator,  // 모더레이터
  admin,      // 관리자
}

class UserRegistration {
  final String email;
  final String username;
  final String displayName;
  final String password;
  final String? bio;
  final String? reason; // 가입 사유

  UserRegistration({
    required this.email,
    required this.username,
    required this.displayName,
    required this.password,
    this.bio,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'display_name': displayName,
      'password': password,
      'bio': bio,
      'reason': reason,
    };
  }
}