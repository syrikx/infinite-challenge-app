import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import 'user_management_screen.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAdmin) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('관리자'),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Text('접근 권한이 없습니다.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('관리자 패널'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.people, color: Colors.blue),
                  title: const Text('사용자 관리'),
                  subtitle: const Text('회원가입 승인 및 사용자 권한 관리'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const UserManagementScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.article, color: Colors.green),
                  title: const Text('매거진 관리'),
                  subtitle: const Text('매거진 승인 및 편집'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Implement magazine management
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('준비 중입니다')),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.forum, color: Colors.orange),
                  title: const Text('커뮤니티 관리'),
                  subtitle: const Text('게시물 관리 및 신고 처리'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Implement community management
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('준비 중입니다')),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.settings, color: Colors.grey),
                  title: const Text('설정'),
                  subtitle: const Text('앱 설정 및 구성'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Implement settings
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('준비 중입니다')),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}