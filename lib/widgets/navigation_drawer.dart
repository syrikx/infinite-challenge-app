import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../theme/app_theme.dart';

class CustomNavigationDrawer extends StatelessWidget {
  const CustomNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = SampleData.getMenuItems();

    return Drawer(
      child: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: const SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Text(
                        'IC',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Infinite Challenge',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Educational Materials',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return ListTile(
                  leading: _getIconForMenuItem(item),
                  title: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _handleMenuItemTap(context, item);
                  },
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'AP® is a trademark registered by the College Board.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Icon _getIconForMenuItem(String item) {
    switch (item) {
      case 'Home':
        return const Icon(Icons.home);
      case 'Products':
        return const Icon(Icons.book);
      case 'AP Calculus':
        return const Icon(Icons.calculate);
      case 'Order':
        return const Icon(Icons.shopping_cart);
      case 'Retail Stores':
        return const Icon(Icons.store);
      case 'Contacts':
        return const Icon(Icons.contact_phone);
      default:
        return const Icon(Icons.menu);
    }
  }

  void _handleMenuItemTap(BuildContext context, String item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to $item'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}