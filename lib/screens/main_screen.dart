import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'magazine/magazine_list_screen.dart';
import 'community/community_list_screen.dart';
import 'books/book_gallery_screen.dart';
import 'admin/admin_panel_screen.dart';
import 'profile/profile_screen.dart';
import 'auth/login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final tabs = _getTabs(authProvider);
        
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: tabs.map((tab) => tab.widget).toList(),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              // Check if login is required for certain tabs
              if (!authProvider.isLoggedIn && tabs[index].requiresAuth) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
                return;
              }
              
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            items: tabs.map((tab) => tab.bottomNavigationBarItem).toList(),
          ),
        );
      },
    );
  }

  List<_TabInfo> _getTabs(AuthProvider authProvider) {
    final tabs = [
      _TabInfo(
        widget: const HomeScreen(),
        bottomNavigationBarItem: const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        requiresAuth: false,
      ),
      _TabInfo(
        widget: const MagazineListScreen(),
        bottomNavigationBarItem: const BottomNavigationBarItem(
          icon: Icon(Icons.article),
          label: '매거진',
        ),
        requiresAuth: false,
      ),
      _TabInfo(
        widget: const BookGalleryScreen(),
        bottomNavigationBarItem: const BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: '교재',
        ),
        requiresAuth: false,
      ),
      _TabInfo(
        widget: const CommunityListScreen(),
        bottomNavigationBarItem: const BottomNavigationBarItem(
          icon: Icon(Icons.forum),
          label: '커뮤니티',
        ),
        requiresAuth: false,
      ),
    ];

    // Add admin tab if user is admin
    if (authProvider.isAdmin) {
      tabs.add(
        _TabInfo(
          widget: const AdminPanelScreen(),
          bottomNavigationBarItem: const BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: '관리자',
          ),
          requiresAuth: true,
        ),
      );
    }

    // Add profile tab
    tabs.add(
      _TabInfo(
        widget: authProvider.isLoggedIn 
            ? const ProfileScreen() 
            : const LoginScreen(),
        bottomNavigationBarItem: BottomNavigationBarItem(
          icon: Icon(authProvider.isLoggedIn ? Icons.person : Icons.login),
          label: authProvider.isLoggedIn ? '프로필' : '로그인',
        ),
        requiresAuth: false,
      ),
    );

    return tabs;
  }
}

class _TabInfo {
  final Widget widget;
  final BottomNavigationBarItem bottomNavigationBarItem;
  final bool requiresAuth;

  _TabInfo({
    required this.widget,
    required this.bottomNavigationBarItem,
    required this.requiresAuth,
  });
}