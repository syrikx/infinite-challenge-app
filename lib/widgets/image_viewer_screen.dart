import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;
  final String title;

  const ImageViewerScreen({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Container(
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(imageUrl),
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 2.0,
          initialScale: PhotoViewComputedScale.contained,
          heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          loadingBuilder: (context, event) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(
              Icons.error,
              color: Colors.white,
              size: 50,
            ),
          ),
        ),
      ),
    );
  }
}