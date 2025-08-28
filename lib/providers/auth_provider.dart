import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  bool _isInitialized = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isInitialized => _isInitialized;
  
  // 새로운 권한 시스템 기반 getters
  bool get canReadMagazine => _currentUser?.canReadMagazine ?? false;
  bool get canWriteMagazine => _currentUser?.canWriteMagazine ?? false;
  bool get canEditMagazine => _currentUser?.canEditMagazine ?? false;
  bool get canDeleteMagazine => _currentUser?.canDeleteMagazine ?? false;
  
  bool get canReadCommunity => _currentUser?.canReadCommunity ?? false;
  bool get canWriteCommunity => _currentUser?.canWriteCommunity ?? false;
  bool get canEditCommunity => _currentUser?.canEditCommunity ?? false;
  bool get canDeleteCommunity => _currentUser?.canDeleteCommunity ?? false;
  bool get canModerateCommunity => _currentUser?.canModerateCommunity ?? false;
  
  bool get canManageUsers => _currentUser?.canManageUsers ?? false;
  bool get canChangeRoles => _currentUser?.canChangeRoles ?? false;
  bool get canViewAnalytics => _currentUser?.canViewAnalytics ?? false;
  bool get canSystemSettings => _currentUser?.canSystemSettings ?? false;
  
  // 기존 호환성을 위한 getters (deprecated - 새로운 권한 시스템 사용 권장)
  bool get canCreatePosts => _currentUser?.canCreatePosts ?? false;
  bool get canModerate => _currentUser?.canModerate ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  UserRole get userRole => _currentUser?.role ?? UserRole.pending;

  Future<void> initialize() async {
    await _authService.initialize();
    _currentUser = _authService.currentUser;
    _isInitialized = true;
    notifyListeners();
  }

  Future<AuthResult> login(String email, String password) async {
    final result = await _authService.login(email, password);
    if (result.isSuccess) {
      _currentUser = _authService.currentUser;
      notifyListeners();
    }
    return result;
  }

  Future<AuthResult> register(UserRegistration registration) async {
    return await _authService.register(registration);
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  // 사용자 관리 메소드들
  Future<List<User>> getPendingUsers() async {
    return await _authService.getPendingUsers();
  }

  Future<List<User>> getAllUsers() async {
    return await _authService.getAllUsers();
  }

  Future<AuthResult> approveUser(String userId) async {
    return await _authService.approveUser(userId);
  }

  Future<AuthResult> approveUserWithRole(String userId, UserRole role) async {
    return await _authService.approveUserWithRole(userId, role);
  }

  Future<AuthResult> rejectUser(String userId) async {
    return await _authService.rejectUser(userId);
  }

  Future<AuthResult> changeUserRole(String userId, UserRole newRole) async {
    return await _authService.changeUserRole(userId, newRole);
  }
}