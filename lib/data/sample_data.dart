import '../models/product.dart';

class SampleData {
  static List<Product> getProducts() {
    return [
      Product(
        id: '1',
        title: 'AP Calculus',
        description: 'Comprehensive AP Calculus materials and practice problems',
        imageUrls: [
          'https://via.placeholder.com/300x400/3498db/ffffff?text=AP+Calculus+1',
          'https://via.placeholder.com/300x400/2ecc71/ffffff?text=AP+Calculus+2',
          'https://via.placeholder.com/300x400/e74c3c/ffffff?text=AP+Calculus+3',
        ],
        category: 'AP Calculus',
      ),
      Product(
        id: '2',
        title: 'Calculus BC',
        description: 'Advanced Calculus BC curriculum and exercises',
        imageUrls: [
          'https://via.placeholder.com/300x400/9b59b6/ffffff?text=Calculus+BC+1',
          'https://via.placeholder.com/300x400/f39c12/ffffff?text=Calculus+BC+2',
          'https://via.placeholder.com/300x400/1abc9c/ffffff?text=Calculus+BC+3',
        ],
        category: 'Calculus BC',
      ),
      Product(
        id: '3',
        title: 'Calculus 12',
        description: 'Grade 12 Calculus textbooks and study materials',
        imageUrls: [
          'https://via.placeholder.com/300x400/34495e/ffffff?text=Calculus+12+1',
          'https://via.placeholder.com/300x400/e67e22/ffffff?text=Calculus+12+2',
          'https://via.placeholder.com/300x400/95a5a6/ffffff?text=Calculus+12+3',
        ],
        category: 'Calculus 12',
      ),
      Product(
        id: '4',
        title: 'Pre-Calculus',
        description: 'Foundation materials for Pre-Calculus studies',
        imageUrls: [
          'https://via.placeholder.com/300x400/2c3e50/ffffff?text=Pre+Calculus+1',
          'https://via.placeholder.com/300x400/8e44ad/ffffff?text=Pre+Calculus+2',
          'https://via.placeholder.com/300x400/16a085/ffffff?text=Pre+Calculus+3',
        ],
        category: 'Pre-Calculus',
      ),
    ];
  }

  static List<String> getMenuItems() {
    return [
      'Home',
      'Products',
      'AP Calculus',
      'Order',
      'Retail Stores',
      'Contacts',
    ];
  }
}