import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/image_viewer_screen.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.product.title),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            Container(
              height: Responsive.isMobile(context) ? 400 : 500,
              child: CarouselSlider(
                options: CarouselOptions(
                  height: double.infinity,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: widget.product.imageUrls.length > 1,
                  autoPlay: false,
                  enlargeCenterPage: false,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                ),
                items: widget.product.imageUrls.map((imageUrl) {
                  return GestureDetector(
                    onTap: () => _showFullScreenImage(context, imageUrl),
                    child: Container(
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.error,
                            color: Colors.grey,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Image indicators
            if (widget.product.imageUrls.length > 1)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.product.imageUrls.asMap().entries.map((entry) {
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == entry.key
                            ? AppTheme.primaryColor
                            : Colors.grey[400],
                      ),
                    );
                  }).toList(),
                ),
              ),

            // Product details
            Padding(
              padding: Responsive.getResponsivePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.title,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.primaryColor,
                      fontSize: Responsive.getResponsiveFontSize(context, 32),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.product.category,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: Responsive.getResponsiveFontSize(context, 24),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: Responsive.getResponsiveFontSize(context, 16),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Features',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: Responsive.getResponsiveFontSize(context, 24),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureList(),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showOrderDialog,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Order Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      'Comprehensive study materials',
      'Step-by-step problem solutions',
      'Practice exercises with answers',
      'Aligned with curriculum standards',
      'Perfect for exam preparation',
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  feature,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: Responsive.getResponsiveFontSize(context, 16),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewerScreen(
          imageUrl: imageUrl,
          title: widget.product.title,
        ),
      ),
    );
  }

  void _showOrderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Order Information'),
          content: Text(
            'To order "${widget.product.title}", please visit our website at infinitechallenge.ca or contact us directly for more information.',
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