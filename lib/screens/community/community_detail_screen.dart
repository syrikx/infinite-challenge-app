import 'package:flutter/material.dart';

class CommunityDetailScreen extends StatelessWidget {
  final String postId;

  const CommunityDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('커뮤니티'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('커뮤니티 상세 - 구현 중'),
      ),
    );
  }
}