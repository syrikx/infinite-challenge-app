import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Infinite Challenge',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Educational Calculus Materials',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFooterButton(
                context,
                'Website',
                Icons.web,
                () => _launchUrl('https://infinitechallenge.ca'),
              ),
              _buildFooterButton(
                context,
                'Contact',
                Icons.email,
                () => _launchUrl('mailto:info@infinitechallenge.ca'),
              ),
              _buildFooterButton(
                context,
                'Order',
                Icons.shopping_cart,
                () => _showOrderInfo(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white30),
          const SizedBox(height: 10),
          const Text(
            'AP® is a trademark registered by the College Board.',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            '© ${DateTime.now().year} Infinite Challenge. All rights reserved.',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  void _showOrderInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Order Information'),
          content: const Text(
            'For ordering information, please visit our website or contact us directly.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}