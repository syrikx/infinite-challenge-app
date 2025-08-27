class Book {
  final String id;
  final String name;
  final String description;
  final String coverImage;
  final int totalPages;
  final List<BookPage> pages;
  final DateTime? createdAt;

  Book({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImage,
    required this.totalPages,
    required this.pages,
    this.createdAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      coverImage: json['cover_image'] ?? '',
      totalPages: json['total_pages'] ?? 0,
      pages: (json['pages'] as List?)
          ?.map((page) => BookPage.fromJson(page))
          .toList() ?? [],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cover_image': coverImage,
      'total_pages': totalPages,
      'pages': pages.map((page) => page.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class BookPage {
  final int pageNumber;
  final String thumbnailPath;
  final String fullImagePath;
  final String? title;
  final String? description;

  BookPage({
    required this.pageNumber,
    required this.thumbnailPath,
    required this.fullImagePath,
    this.title,
    this.description,
  });

  factory BookPage.fromJson(Map<String, dynamic> json) {
    return BookPage(
      pageNumber: json['page_number'],
      thumbnailPath: json['thumbnail_path'],
      fullImagePath: json['full_image_path'],
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page_number': pageNumber,
      'thumbnail_path': thumbnailPath,
      'full_image_path': fullImagePath,
      'title': title,
      'description': description,
    };
  }
}

class BookCategory {
  final String id;
  final String name;
  final String description;
  final List<Book> books;

  BookCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.books,
  });

  factory BookCategory.fromJson(Map<String, dynamic> json) {
    return BookCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      books: (json['books'] as List?)
          ?.map((book) => Book.fromJson(book))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'books': books.map((book) => book.toJson()).toList(),
    };
  }
}