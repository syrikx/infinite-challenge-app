import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../widgets/image_viewer_screen.dart';
import '../theme/app_theme.dart';

class ProductGallery extends StatefulWidget {
  final Product product;

  const ProductGallery({
    super.key,
    required this.product,
  });

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.product.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          CarouselSlider(
            options: CarouselOptions(
              height: 300,
              aspectRatio: 3/4,
              viewportFraction: 0.8,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: false,
              enlargeCenterPage: true,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
            ),
            items: widget.product.imageUrls.map((imageUrl) {
              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () => _showFullScreenImage(context, imageUrl),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
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
                    ),
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.product.imageUrls.asMap().entries.map((entry) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImageIndex == entry.key
                      ? AppTheme.primaryColor
                      : Colors.grey[400],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
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
}