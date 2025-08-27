import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../utils/responsive.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;

  const ProductGrid({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: Responsive.getGridCrossAxisCount(context),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}