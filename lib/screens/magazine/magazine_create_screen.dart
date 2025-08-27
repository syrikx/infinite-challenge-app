import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/magazine_article.dart';
import '../../services/database_service.dart';
import '../../providers/auth_provider.dart';

class MagazineCreateScreen extends StatefulWidget {
  final MagazineArticle? editArticle;

  const MagazineCreateScreen({
    super.key,
    this.editArticle,
  });

  @override
  State<MagazineCreateScreen> createState() => _MagazineCreateScreenState();
}

class _MagazineCreateScreenState extends State<MagazineCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _excerptController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  final DatabaseService _db = DatabaseService();
  final ImagePicker _picker = ImagePicker();
  
  ArticleCategory _selectedCategory = ArticleCategory.general;
  bool _isFeatured = false;
  bool _isLoading = false;
  List<String> _imageUrls = [];
  String? _featuredImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.editArticle != null) {
      _titleController.text = widget.editArticle!.title;
      _excerptController.text = widget.editArticle!.excerpt;
      _contentController.text = widget.editArticle!.content;
      _tagsController.text = widget.editArticle!.tags.join(', ');
      _selectedCategory = widget.editArticle!.category;
      _isFeatured = widget.editArticle!.isFeatured;
      _imageUrls = List.from(widget.editArticle!.imageUrls);
      _featuredImageUrl = widget.editArticle!.featuredImageUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _excerptController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickFeaturedImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (image != null) {
      // TODO: Upload image to server and get URL
      // For now, we'll use a placeholder URL
      setState(() {
        _featuredImageUrl = 'https://via.placeholder.com/800x400.png?text=Featured+Image';
      });
    }
  }

  Future<void> _pickContentImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    for (final image in images) {
      // TODO: Upload images to server and get URLs
      // For now, we'll use placeholder URLs
      setState(() {
        _imageUrls.add('https://via.placeholder.com/800x600.png?text=Content+Image');
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
  }

  void _removeFeaturedImage() {
    setState(() {
      _featuredImageUrl = null;
    });
  }

  List<String> _parseTags(String tagsText) {
    return tagsText
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  Future<void> _saveArticle() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      Fluttertoast.showToast(msg: '로그인이 필요합니다');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final article = MagazineArticle(
        id: widget.editArticle?.id ?? '',
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        excerpt: _excerptController.text.trim(),
        authorId: authProvider.currentUser!.id,
        authorName: authProvider.currentUser!.displayName,
        tags: _parseTags(_tagsController.text),
        featuredImageUrl: _featuredImageUrl,
        imageUrls: _imageUrls,
        category: _selectedCategory,
        isFeatured: _isFeatured && authProvider.isAdmin,
        status: ArticleStatus.draft, // Initially save as draft
        createdAt: widget.editArticle?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.editArticle == null) {
        await _db.insertArticle(article);
        Fluttertoast.showToast(msg: '매거진이 저장되었습니다');
      } else {
        // TODO: Update article in database
        Fluttertoast.showToast(msg: '매거진이 수정되었습니다');
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: '저장 중 오류가 발생했습니다: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editArticle != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '매거진 수정' : '매거진 작성'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveArticle,
            child: const Text(
              '저장',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목 *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '제목을 입력해주세요';
                  }
                  if (value.length > 100) {
                    return '제목은 100자 이하여야 합니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<ArticleCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: '카테고리',
                  border: OutlineInputBorder(),
                ),
                items: ArticleCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(_getCategoryName(category)),
                  );
                }).toList(),
                onChanged: (category) {
                  if (category != null) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Excerpt
              TextFormField(
                controller: _excerptController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '요약 *',
                  border: OutlineInputBorder(),
                  helperText: '매거진 목록에서 보여질 요약 내용',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '요약을 입력해주세요';
                  }
                  if (value.length > 200) {
                    return '요약은 200자 이하여야 합니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Featured Image
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '대표 이미지',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          TextButton.icon(
                            onPressed: _pickFeaturedImage,
                            icon: const Icon(Icons.add_a_photo),
                            label: const Text('선택'),
                          ),
                        ],
                      ),
                      if (_featuredImageUrl != null) ...[
                        const SizedBox(height: 8),
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _featuredImageUrl!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.error),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.red,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  onPressed: _removeFeaturedImage,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Content
              TextFormField(
                controller: _contentController,
                maxLines: 15,
                decoration: const InputDecoration(
                  labelText: '내용 *',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '내용을 입력해주세요';
                  }
                  if (value.length < 10) {
                    return '내용은 최소 10자 이상이어야 합니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Content Images
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '첨부 이미지',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          TextButton.icon(
                            onPressed: _pickContentImages,
                            icon: const Icon(Icons.add_photo_alternate),
                            label: const Text('추가'),
                          ),
                        ],
                      ),
                      if (_imageUrls.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ...(_imageUrls.asMap().entries.map((entry) {
                          final index = entry.key;
                          final imageUrl = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 150,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.error),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.red,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white),
                                      onPressed: () => _removeImage(index),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        })),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tags
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: '태그',
                  border: OutlineInputBorder(),
                  helperText: '쉼표로 구분하여 입력 (예: 수학, 미적분학, 교육)',
                ),
              ),
              const SizedBox(height: 16),

              // Featured toggle (admin only)
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  if (!authProvider.isAdmin) return const SizedBox.shrink();
                  
                  return SwitchListTile(
                    title: const Text('추천 매거진으로 설정'),
                    subtitle: const Text('메인 페이지에서 강조 표시됩니다'),
                    value: _isFeatured,
                    onChanged: (value) {
                      setState(() {
                        _isFeatured = value;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveArticle,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isEditing ? '수정하기' : '저장하기',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryName(ArticleCategory category) {
    switch (category) {
      case ArticleCategory.general:
        return '일반';
      case ArticleCategory.calculus:
        return '미적분학';
      case ArticleCategory.algebra:
        return '대수학';
      case ArticleCategory.geometry:
        return '기하학';
      case ArticleCategory.statistics:
        return '통계학';
      case ArticleCategory.research:
        return '연구';
      case ArticleCategory.news:
        return '뉴스';
      case ArticleCategory.tutorial:
        return '튜토리얼';
    }
  }
}