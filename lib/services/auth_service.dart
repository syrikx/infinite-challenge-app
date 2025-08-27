import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _api = ApiService();
  User? _currentUser;
  
  static const String _currentUserKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get canCreatePosts => _currentUser?.canCreatePosts ?? false;
  bool get canModerate => _currentUser?.canModerate ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<void> initialize() async {
    try {
      // Try to get current user from API if we have a token
      _currentUser = await _api.getCurrentUser();
      await _saveUserSession();
    } catch (e) {
      // If API call fails, try to load from local storage
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      
      if (isLoggedIn) {
        final userJson = prefs.getString(_currentUserKey);
        if (userJson != null) {
          try {
            _currentUser = User.fromJson(jsonDecode(userJson));
          } catch (e) {
            // 사용자 데이터가 손상된 경우 로그아웃
            await logout();
          }
        }
      }
    }
  }

  Future<AuthResult> register(UserRegistration registration) async {
    try {
      final response = await _api.register(registration);
      return AuthResult.success(response.message);
    } catch (e) {
      if (e is ApiException) {
        return AuthResult.error(e.message);
      }
      return AuthResult.error('회원가입 중 오류가 발생했습니다: $e');
    }
  }

  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _api.login(email, password);
      
      if (response.user != null) {
        _currentUser = response.user;
        await _saveUserSession();
        return AuthResult.success(response.message);
      } else {
        return AuthResult.error('로그인 응답이 올바르지 않습니다.');
      }
    } catch (e) {
      if (e is ApiException) {
        return AuthResult.error(e.message);
      }
      return AuthResult.error('로그인 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } finally {
      _currentUser = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
      await prefs.setBool(_isLoggedInKey, false);
    }
  }

  Future<void> _saveUserSession() async {
    if (_currentUser == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, jsonEncode(_currentUser!.toJson()));
    await prefs.setBool(_isLoggedInKey, true);
  }

  Future<List<User>> getPendingUsers() async {
    if (!isAdmin) {
      throw Exception('권한이 없습니다.');
    }
    try {
      return await _api.getPendingUsers();
    } catch (e) {
      throw Exception('대기 중인 사용자를 불러오는데 실패했습니다: $e');
    }
  }

  Future<AuthResult> approveUser(String userId) async {
    if (!isAdmin) {
      return AuthResult.error('권한이 없습니다.');
    }

    try {
      await _api.approveUser(userId, 'member');
      return AuthResult.success('사용자가 승인되었습니다.');
    } catch (e) {
      if (e is ApiException) {
        return AuthResult.error(e.message);
      }
      return AuthResult.error('승인 중 오류가 발생했습니다: $e');
    }
  }

  Future<AuthResult> rejectUser(String userId) async {
    if (!isAdmin) {
      return AuthResult.error('권한이 없습니다.');
    }

    try {
      await _api.rejectUser(userId);
      return AuthResult.success('사용자가 거부되었습니다.');
    } catch (e) {
      if (e is ApiException) {
        return AuthResult.error(e.message);
      }
      return AuthResult.error('거부 중 오류가 발생했습니다: $e');
    }
  }

  Future<AuthResult> changeUserRole(String userId, UserRole newRole) async {
    if (!isAdmin) {
      return AuthResult.error('권한이 없습니다.');
    }

    try {
      await _api.changeUserRole(userId, newRole.name);
      return AuthResult.success('사용자 역할이 변경되었습니다.');
    } catch (e) {
      if (e is ApiException) {
        return AuthResult.error(e.message);
      }
      return AuthResult.error('역할 변경 중 오류가 발생했습니다: $e');
    }
  }
}

class AuthResult {
  final bool isSuccess;
  final String message;

  AuthResult.success(this.message) : isSuccess = true;
  AuthResult.error(this.message) : isSuccess = false;
}