class Product {
  final String id;
  final String title;
  final String description;
  final List<String> imageUrls;
  final String category;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrls: List<String>.from(json['imageUrls'] as List),
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
      'category': category,
    };
  }
}