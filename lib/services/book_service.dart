import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/book.dart';

class BookService {
  static final BookService _instance = BookService._internal();
  factory BookService() => _instance;
  BookService._internal();

  List<Book>? _cachedBooks;
  
  // 로컬 에셋에서 책 데이터 로드
  Future<List<Book>> getBooks() async {
    if (_cachedBooks != null) return _cachedBooks!;
    
    try {
      // 기본 책 데이터 생성 (실제로는 assets/images/books/index.json에서 로드)
      _cachedBooks = await _loadBooksFromAssets();
      return _cachedBooks!;
    } catch (e) {
      print('Error loading books: $e');
      return [];
    }
  }

  Future<List<Book>> _loadBooksFromAssets() async {
    // Calculus 12 교재 데이터
    final calculus12Pages = <BookPage>[];
    for (int i = 1; i <= 28; i++) {
      calculus12Pages.add(BookPage(
        pageNumber: i,
        thumbnailPath: 'assets/images/books/calculus_12/thumbnails/page_${i.toString().padLeft(2, '0')}.jpg',
        fullImagePath: 'assets/images/books/calculus_12/full/page_${i.toString().padLeft(2, '0')}.jpg',
        title: 'Page $i',
        description: 'Calculus 12 - Page $i',
      ));
    }

    final books = [
      Book(
        id: 'calculus_12',
        name: 'Calculus 12',
        description: 'Advanced Calculus for Grade 12 students. Comprehensive coverage of differential and integral calculus.',
        coverImage: 'assets/images/books/calculus_12/thumbnails/page_01.jpg',
        totalPages: 28,
        pages: calculus12Pages,
        createdAt: DateTime.now(),
      ),
    ];

    return books;
  }

  Future<Book?> getBookById(String bookId) async {
    final books = await getBooks();
    try {
      return books.firstWhere((book) => book.id == bookId);
    } catch (e) {
      return null;
    }
  }

  Future<List<Book>> searchBooks(String query) async {
    if (query.isEmpty) return await getBooks();
    
    final books = await getBooks();
    return books.where((book) => 
      book.name.toLowerCase().contains(query.toLowerCase()) ||
      book.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // 책의 특정 페이지 정보 가져오기
  BookPage? getBookPage(String bookId, int pageNumber) {
    if (_cachedBooks == null) return null;
    
    try {
      final book = _cachedBooks!.firstWhere((book) => book.id == bookId);
      return book.pages.firstWhere((page) => page.pageNumber == pageNumber);
    } catch (e) {
      return null;
    }
  }

  // 다음/이전 페이지 정보
  BookPage? getNextPage(String bookId, int currentPage) {
    final nextPageNumber = currentPage + 1;
    return getBookPage(bookId, nextPageNumber);
  }

  BookPage? getPreviousPage(String bookId, int currentPage) {
    final previousPageNumber = currentPage - 1;
    if (previousPageNumber < 1) return null;
    return getBookPage(bookId, previousPageNumber);
  }
}