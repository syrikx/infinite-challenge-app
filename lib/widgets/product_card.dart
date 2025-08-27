import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../screens/product_detail_screen.dart';
import '../theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 3/4,
                child: CachedNetworkImage(
                  imageUrl: product.imageUrls.first,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.book,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      product.category,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}