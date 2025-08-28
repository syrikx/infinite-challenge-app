import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;
  String _selectedFilter = 'pending'; // 'all', 'pending', 'active'

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
  }

  Future<void> _loadAllUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final users = await authProvider.getAllUsers();
      
      if (mounted) {
        setState(() {
          _allUsers = users;
          _filterUsers();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Fluttertoast.showToast(
          msg: '사용자 목록을 불러오는 중 오류가 발생했습니다',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  void _filterUsers() {
    switch (_selectedFilter) {
      case 'pending':
        _filteredUsers = _allUsers.where((user) => user.role == UserRole.pending).toList();
        break;
      case 'active':
        _filteredUsers = _allUsers.where((user) => user.role != UserRole.pending).toList();
        break;
      case 'all':
      default:
        _filteredUsers = List.from(_allUsers);
        break;
    }
  }

  // 역할 선택 다이얼로그
  Future<UserRole?> _showRoleSelectionDialog() async {
    return await showDialog<UserRole>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사용자 역할 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserRole.values.where((role) => role != UserRole.pending).map((role) {
            return ListTile(
              title: Text(_getRoleDisplayName(role)),
              subtitle: Text(_getRoleDescription(role)),
              onTap: () => Navigator.of(context).pop(role),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  // 사용자 역할 변경 다이얼로그
  Future<void> _showUserRoleChangeDialog(User user) async {
    final selectedRole = await _showRoleSelectionDialog();
    if (selectedRole == null || selectedRole == user.role) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('역할 변경'),
        content: Text(
          '${user.displayName}님의 역할을 "${_getRoleDisplayName(user.role)}"에서 "${_getRoleDisplayName(selectedRole)}"로 변경하시겠습니까?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('변경'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.changeUserRole(user.id, selectedRole);
      
      if (result.isSuccess) {
        Fluttertoast.showToast(
          msg: '${user.displayName}님의 역할이 변경되었습니다',
          backgroundColor: Colors.green,
        );
        _loadAllUsers();
      } else {
        Fluttertoast.showToast(
          msg: result.message,
          backgroundColor: Colors.red,
        );
      }
    }
  }

  Future<void> _approveUser(String userId, String userName) async {
    // 역할 선택 다이얼로그 표시
    final selectedRole = await _showRoleSelectionDialog();
    if (selectedRole == null) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.approveUserWithRole(userId, selectedRole);
    
    if (result.isSuccess) {
      final roleDisplayName = _getRoleDisplayName(selectedRole);
      Fluttertoast.showToast(
        msg: '$userName님을 $roleDisplayName로 승인했습니다',
        backgroundColor: Colors.green,
      );
      _loadAllUsers();
    } else {
      Fluttertoast.showToast(
        msg: result.message,
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _rejectUser(String userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('가입 거부'),
        content: Text('$userName님의 가입을 거부하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('거부'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.rejectUser(userId);
      
      if (result.isSuccess) {
        Fluttertoast.showToast(
          msg: '$userName님의 가입이 거부되었습니다',
          backgroundColor: Colors.orange,
        );
        _loadAllUsers();
      } else {
        Fluttertoast.showToast(
          msg: result.message,
          backgroundColor: Colors.red,
        );
      }
    }
  }

  String _getRoleDisplayName(UserRole role) {
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

  String _getRoleDescription(UserRole role) {
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

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.pending:
        return Colors.orange;
      case UserRole.freeUser:
        return Colors.grey;
      case UserRole.user:
        return Colors.blue;
      case UserRole.operator:
        return Colors.purple;
      case UserRole.admin:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사용자 관리'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
                _filterUsers();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pending',
                child: Text('승인 대기만'),
              ),
              const PopupMenuItem(
                value: 'active',
                child: Text('활성 사용자만'),
              ),
              const PopupMenuItem(
                value: 'all',
                child: Text('전체'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAllUsers,
              child: _filteredUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedFilter == 'pending' 
                              ? Icons.check_circle 
                              : Icons.people,
                            size: 64, 
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFilter == 'pending'
                              ? '승인 대기 중인 사용자가 없습니다'
                              : '조건에 맞는 사용자가 없습니다',
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: _getRoleColor(user.role),
                                      child: Text(
                                        user.displayName.isNotEmpty
                                            ? user.displayName[0].toUpperCase()
                                            : 'U',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                user.displayName,
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: _getRoleColor(user.role),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  _getRoleDisplayName(user.role),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '@${user.username}',
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                          Text(
                                            user.email,
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                
                                if (user.bio != null && user.bio!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    '자기소개',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(user.bio!),
                                ],
                                
                                const SizedBox(height: 12),
                                Text(
                                  '가입일: ${user.createdAt.toString().substring(0, 16)}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                if (user.role == UserRole.pending) ...[
                                  // 승인 대기 사용자 버튼
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _approveUser(user.id, user.displayName),
                                          icon: const Icon(Icons.check),
                                          label: const Text('승인'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _rejectUser(user.id, user.displayName),
                                          icon: const Icon(Icons.close),
                                          label: const Text('거부'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red,
                                            side: const BorderSide(color: Colors.red),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  // 활성 사용자 버튼
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _showUserRoleChangeDialog(user),
                                          icon: const Icon(Icons.edit),
                                          label: const Text('역할 변경'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.blue,
                                            side: const BorderSide(color: Colors.blue),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        _getRoleDescription(user.role),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}