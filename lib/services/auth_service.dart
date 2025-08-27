import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseService _db = DatabaseService();
  User? _currentUser;
  
  static const String _currentUserKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get canCreatePosts => _currentUser?.canCreatePosts ?? false;
  bool get canModerate => _currentUser?.canModerate ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<void> initialize() async {
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

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<AuthResult> register(UserRegistration registration) async {
    try {
      // 이메일 중복 확인
      final existingUser = await _db.getUserByEmail(registration.email);
      if (existingUser != null) {
        return AuthResult.error('이미 등록된 이메일입니다.');
      }

      // 패스워드 해시화
      final passwordHash = _hashPassword(registration.password);
      
      // 사용자 생성
      final userId = await _db.insertUser(registration, passwordHash);
      
      return AuthResult.success('회원가입 신청이 완료되었습니다. 관리자 승인을 기다려주세요.');
    } catch (e) {
      return AuthResult.error('회원가입 중 오류가 발생했습니다: $e');
    }
  }

  Future<AuthResult> login(String email, String password) async {
    try {
      // 사용자 확인
      final user = await _db.getUserByEmail(email);
      if (user == null) {
        return AuthResult.error('존재하지 않는 사용자입니다.');
      }

      if (!user.isActive) {
        return AuthResult.error('비활성화된 계정입니다.');
      }

      if (user.role == UserRole.pending) {
        return AuthResult.error('관리자 승인 대기 중입니다.');
      }

      // 패스워드 확인
      final storedHash = await _db.getUserPasswordHash(email);
      final inputHash = _hashPassword(password);
      
      if (storedHash != inputHash) {
        return AuthResult.error('잘못된 비밀번호입니다.');
      }

      // 로그인 성공
      _currentUser = user;
      await _saveUserSession();
      
      return AuthResult.success('로그인 성공');
    } catch (e) {
      return AuthResult.error('로그인 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    await prefs.setBool(_isLoggedInKey, false);
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
    return await _db.getPendingUsers();
  }

  Future<AuthResult> approveUser(String userId) async {
    if (!isAdmin) {
      return AuthResult.error('권한이 없습니다.');
    }

    try {
      await _db.updateUserRole(userId, UserRole.member);
      return AuthResult.success('사용자가 승인되었습니다.');
    } catch (e) {
      return AuthResult.error('승인 중 오류가 발생했습니다: $e');
    }
  }

  Future<AuthResult> rejectUser(String userId) async {
    if (!isAdmin) {
      return AuthResult.error('권한이 없습니다.');
    }

    try {
      // 실제로는 사용자를 삭제하거나 거부 상태로 변경
      // 여기서는 간단히 비활성화
      await _db.updateUserRole(userId, UserRole.guest);
      return AuthResult.success('사용자가 거부되었습니다.');
    } catch (e) {
      return AuthResult.error('거부 중 오류가 발생했습니다: $e');
    }
  }

  Future<AuthResult> changeUserRole(String userId, UserRole newRole) async {
    if (!isAdmin) {
      return AuthResult.error('권한이 없습니다.');
    }

    try {
      await _db.updateUserRole(userId, newRole);
      return AuthResult.success('사용자 역할이 변경되었습니다.');
    } catch (e) {
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