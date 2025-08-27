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
  bool get canCreatePosts => _currentUser?.canCreatePosts ?? false;
  bool get canModerate => _currentUser?.canModerate ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  UserRole get userRole => _currentUser?.role ?? UserRole.guest;

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

  Future<List<User>> getPendingUsers() async {
    return await _authService.getPendingUsers();
  }

  Future<AuthResult> approveUser(String userId) async {
    return await _authService.approveUser(userId);
  }

  Future<AuthResult> rejectUser(String userId) async {
    return await _authService.rejectUser(userId);
  }

  Future<AuthResult> changeUserRole(String userId, UserRole newRole) async {
    return await _authService.changeUserRole(userId, newRole);
  }
}