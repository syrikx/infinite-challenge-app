import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/navigation_drawer.dart' as custom;
import '../widgets/product_grid.dart';
import '../data/sample_data.dart';
import '../utils/responsive.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = SampleData.getProducts();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Products'),
      drawer: const custom.CustomNavigationDrawer(),
      body: SingleChildScrollView(
        padding: Responsive.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Our Educational Materials',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: Responsive.getResponsiveFontSize(context, 32),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Comprehensive calculus study materials for all levels',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: Responsive.getResponsiveFontSize(context, 16),
              ),
            ),
            const SizedBox(height: 24),
            ProductGrid(products: products),
          ],
        ),
      ),
    );
  }
}