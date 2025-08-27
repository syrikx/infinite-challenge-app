import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../models/book.dart';

class BookViewerScreen extends StatefulWidget {
  final Book book;
  final int initialPage;

  const BookViewerScreen({
    super.key,
    required this.book,
    this.initialPage = 0,
  });

  @override
  State<BookViewerScreen> createState() => _BookViewerScreenState();
}

class _BookViewerScreenState extends State<BookViewerScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _showAppBar = true;
  bool _showBottomBar = true;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleBars() {
    setState(() {
      _showAppBar = !_showAppBar;
      _showBottomBar = !_showBottomBar;
    });
  }

  void _goToPage(int page) {
    if (page >= 0 && page < widget.book.pages.length) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _showAppBar
          ? AppBar(
              title: Text(widget.book.name),
              backgroundColor: Colors.black.withOpacity(0.7),
              foregroundColor: Colors.white,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: _showBookInfo,
                ),
              ],
            )
          : null,
      body: Stack(
        children: [
          // 이미지 갤러리
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              final page = widget.book.pages[index];
              return PhotoViewGalleryPageOptions(
                imageProvider: AssetImage(page.fullImagePath),
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2.0,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.white54,
                            size: 48,
                          ),
                          SizedBox(height: 16),
                          Text(
                            '이미지를 불러올 수 없습니다',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            itemCount: widget.book.pages.length,
            loadingBuilder: (context, event) => Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  value: event == null
                      ? 0
                      : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
          ),
          
          // 탭하면 UI 토글
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleBars,
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _showBottomBar
          ? _buildBottomBar()
          : null,
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        child: Row(
          children: [
            // 이전 페이지 버튼
            IconButton(
              onPressed: _currentPage > 0 ? () => _goToPage(_currentPage - 1) : null,
              icon: const Icon(Icons.chevron_left, color: Colors.white),
              iconSize: 32,
            ),
            
            const SizedBox(width: 8),
            
            // 페이지 정보
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Page ${_currentPage + 1} of ${widget.book.pages.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: (_currentPage + 1) / widget.book.pages.length,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 8),
            
            // 다음 페이지 버튼
            IconButton(
              onPressed: _currentPage < widget.book.pages.length - 1
                  ? () => _goToPage(_currentPage + 1)
                  : null,
              icon: const Icon(Icons.chevron_right, color: Colors.white),
              iconSize: 32,
            ),
            
            const SizedBox(width: 8),
            
            // 페이지 점프 버튼
            IconButton(
              onPressed: _showPageJumpDialog,
              icon: const Icon(Icons.list, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.book.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.book.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.pages, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Text('총 ${widget.book.totalPages}페이지'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.book, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Text('현재 ${_currentPage + 1}페이지'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPageJumpDialog() {
    final TextEditingController pageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('페이지 이동'),
        content: TextField(
          controller: pageController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '페이지 번호 (1-${widget.book.totalPages})',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final pageNum = int.tryParse(pageController.text);
              if (pageNum != null && pageNum >= 1 && pageNum <= widget.book.totalPages) {
                Navigator.pop(context);
                _goToPage(pageNum - 1);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('1부터 ${widget.book.totalPages} 사이의 숫자를 입력하세요'),
                  ),
                );
              }
            },
            child: const Text('이동'),
          ),
        ],
      ),
    );
  }
}