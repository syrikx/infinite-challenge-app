import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/navigation_drawer.dart' as custom;
import '../widgets/product_gallery.dart';
import '../widgets/footer_section.dart';
import '../data/sample_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = SampleData.getProducts();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Infinite Challenge'),
      drawer: const custom.CustomNavigationDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Educational Calculus Materials',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Comprehensive study materials for calculus students',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ...products.map((product) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: ProductGallery(product: product),
            )),
            const FooterSection(),
          ],
        ),
      ),
    );
  }
}