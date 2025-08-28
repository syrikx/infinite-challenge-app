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
  final UserPermissions? permissions;
  final int roleLevel;

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
    this.permissions,
    this.roleLevel = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      displayName: json['displayName'] ?? json['display_name'],
      role: UserRole.values.byName(json['role']),
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      lastLoginAt: json['lastLoginAt'] != null 
        ? DateTime.parse(json['lastLoginAt']) 
        : (json['last_login_at'] != null ? DateTime.parse(json['last_login_at']) : null),
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      profileImageUrl: json['profileImageUrl'] ?? json['profile_image_url'],
      bio: json['bio'],
      permissions: json['permissions'] != null 
          ? UserPermissions.fromJson(json['permissions']) 
          : null,
      roleLevel: json['roleLevel'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'displayName': displayName,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isActive': isActive,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'permissions': permissions?.toJson(),
      'roleLevel': roleLevel,
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
    UserPermissions? permissions,
    int? roleLevel,
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
      permissions: permissions ?? this.permissions,
      roleLevel: roleLevel ?? this.roleLevel,
    );
  }

  // 새로운 권한 시스템 기반 메소드들
  bool get canReadMagazine => permissions?.canReadMagazine ?? false;
  bool get canWriteMagazine => permissions?.canWriteMagazine ?? false;
  bool get canEditMagazine => permissions?.canEditMagazine ?? false;
  bool get canDeleteMagazine => permissions?.canDeleteMagazine ?? false;
  
  bool get canReadCommunity => permissions?.canReadCommunity ?? false;
  bool get canWriteCommunity => permissions?.canWriteCommunity ?? false;
  bool get canEditCommunity => permissions?.canEditCommunity ?? false;
  bool get canDeleteCommunity => permissions?.canDeleteCommunity ?? false;
  bool get canModerateCommunity => permissions?.canModerateCommunity ?? false;
  
  bool get canManageUsers => permissions?.canManageUsers ?? false;
  bool get canChangeRoles => permissions?.canChangeRoles ?? false;
  bool get canViewAnalytics => permissions?.canViewAnalytics ?? false;
  bool get canSystemSettings => permissions?.canSystemSettings ?? false;

  // 기존 호환성을 위한 메소드들 (deprecated - 새로운 권한 시스템 사용 권장)
  bool get canCreatePosts => canWriteCommunity;
  bool get canModerate => canModerateCommunity;
  bool get isAdmin => role == UserRole.admin;
  
  // 역할 레벨 체크
  bool hasRoleLevel(int minimumLevel) => roleLevel >= minimumLevel;
  
  // 역할별 한글 이름
  String get roleDisplayName {
    switch (role) {
      case UserRole.pending:
        return '승인 대기';
      case UserRole.freeUser:
        return '무료사용자';
      case UserRole.user:
        return '사용자';
      case UserRole.operator:
        return '운영자';
      case UserRole.admin:
        return '관리자';
    }
  }
  
  // 역할별 설명
  String get roleDescription {
    switch (role) {
      case UserRole.pending:
        return '관리자 승인 대기 중';
      case UserRole.freeUser:
        return '매거진 및 커뮤니티 보기만 가능';
      case UserRole.user:
        return '커뮤니티 쓰기 가능';
      case UserRole.operator:
        return '매거진 작성, 수정 가능';
      case UserRole.admin:
        return '모든 기능과 권한 변경 가능';
    }
  }
}

// 새로운 4단계 권한 시스템
enum UserRole {
  pending,    // 0 - 승인 대기
  freeUser,   // 1 - 무료사용자 (매거진 및 커뮤니티 보기만 가능)
  user,       // 2 - 사용자 (커뮤니티 쓰기 가능)
  operator,   // 3 - 운영자 (매거진 작성, 수정 가능)
  admin,      // 4 - 관리자 (모든 기능과 권한 변경 가능)
}

// 권한 정보를 담는 클래스
class UserPermissions {
  final bool canReadMagazine;
  final bool canWriteMagazine;
  final bool canEditMagazine;
  final bool canDeleteMagazine;
  
  final bool canReadCommunity;
  final bool canWriteCommunity;
  final bool canEditCommunity;
  final bool canDeleteCommunity;
  final bool canModerateCommunity;
  
  final bool canManageUsers;
  final bool canChangeRoles;
  final bool canViewAnalytics;
  final bool canSystemSettings;

  UserPermissions({
    required this.canReadMagazine,
    required this.canWriteMagazine,
    required this.canEditMagazine,
    required this.canDeleteMagazine,
    required this.canReadCommunity,
    required this.canWriteCommunity,
    required this.canEditCommunity,
    required this.canDeleteCommunity,
    required this.canModerateCommunity,
    required this.canManageUsers,
    required this.canChangeRoles,
    required this.canViewAnalytics,
    required this.canSystemSettings,
  });

  factory UserPermissions.fromJson(Map<String, dynamic> json) {
    return UserPermissions(
      canReadMagazine: json['canReadMagazine'] ?? false,
      canWriteMagazine: json['canWriteMagazine'] ?? false,
      canEditMagazine: json['canEditMagazine'] ?? false,
      canDeleteMagazine: json['canDeleteMagazine'] ?? false,
      canReadCommunity: json['canReadCommunity'] ?? false,
      canWriteCommunity: json['canWriteCommunity'] ?? false,
      canEditCommunity: json['canEditCommunity'] ?? false,
      canDeleteCommunity: json['canDeleteCommunity'] ?? false,
      canModerateCommunity: json['canModerateCommunity'] ?? false,
      canManageUsers: json['canManageUsers'] ?? false,
      canChangeRoles: json['canChangeRoles'] ?? false,
      canViewAnalytics: json['canViewAnalytics'] ?? false,
      canSystemSettings: json['canSystemSettings'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'canReadMagazine': canReadMagazine,
      'canWriteMagazine': canWriteMagazine,
      'canEditMagazine': canEditMagazine,
      'canDeleteMagazine': canDeleteMagazine,
      'canReadCommunity': canReadCommunity,
      'canWriteCommunity': canWriteCommunity,
      'canEditCommunity': canEditCommunity,
      'canDeleteCommunity': canDeleteCommunity,
      'canModerateCommunity': canModerateCommunity,
      'canManageUsers': canManageUsers,
      'canChangeRoles': canChangeRoles,
      'canViewAnalytics': canViewAnalytics,
      'canSystemSettings': canSystemSettings,
    };
  }
}

class UserRegistration {
  final String email;
  final String username;
  final String displayName;
  final String password;
  final String? bio;
  final String? reason;

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
      'displayName': displayName,
      'password': password,
      'bio': bio,
      'reason': reason,
    };
  }
}