const express = require('express');
const MagazineArticle = require('../models/MagazineArticle');
const { authenticateToken, canCreatePosts, isAdmin } = require('../middleware/auth');

const router = express.Router();

// Get published articles
router.get('/', async (req, res) => {
  try {
    const { page = 1, limit = 20, category, search } = req.query;
    const skip = (page - 1) * limit;

    let query = { status: 'published' };
    
    if (category && category !== 'general') {
      query.category = category;
    }

    if (search) {
      query.$or = [
        { title: { $regex: search, $options: 'i' } },
        { content: { $regex: search, $options: 'i' } },
        { tags: { $in: [new RegExp(search, 'i')] } }
      ];
    }

    const articles = await MagazineArticle.find(query)
      .populate('author', 'displayName profileImageUrl')
      .sort({ isFeatured: -1, publishedAt: -1 })
      .limit(parseInt(limit))
      .skip(skip);

    const total = await MagazineArticle.countDocuments(query);

    res.json({
      articles,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / limit),
        totalArticles: total,
        hasNext: skip + articles.length < total,
        hasPrev: page > 1
      }
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch articles',
      message: error.message
    });
  }
});

// Get single article
router.get('/:id', async (req, res) => {
  try {
    const article = await MagazineArticle.findById(req.params.id)
      .populate('author', 'displayName profileImageUrl bio');

    if (!article) {
      return res.status(404).json({
        error: 'Article not found',
        message: 'Article with the specified ID does not exist'
      });
    }

    // Increment view count
    article.viewCount += 1;
    await article.save();

    res.json({ article });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch article',
      message: error.message
    });
  }
});

// Create new article
router.post('/', authenticateToken, canCreatePosts, async (req, res) => {
  try {
    const {
      title,
      content,
      excerpt,
      tags = [],
      featuredImageUrl,
      imageUrls = [],
      category = 'general',
      isFeatured = false
    } = req.body;

    // Only admins can set featured articles
    const canSetFeatured = req.user.isAdmin && isFeatured;

    const article = new MagazineArticle({
      title,
      content,
      excerpt,
      author: req.user._id,
      authorName: req.user.displayName,
      tags,
      featuredImageUrl,
      imageUrls,
      category,
      isFeatured: canSetFeatured,
      status: 'draft'
    });

    await article.save();
    await article.populate('author', 'displayName profileImageUrl');

    res.status(201).json({
      message: 'Article created successfully',
      article
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to create article',
      message: error.message
    });
  }
});

// Update article
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    const article = await MagazineArticle.findById(req.params.id);

    if (!article) {
      return res.status(404).json({
        error: 'Article not found',
        message: 'Article with the specified ID does not exist'
      });
    }

    // Check permissions
    const canEdit = req.user.isAdmin || 
                   req.user._id.toString() === article.author.toString();
    
    if (!canEdit) {
      return res.status(403).json({
        error: 'Permission denied',
        message: 'You can only edit your own articles'
      });
    }

    const {
      title,
      content,
      excerpt,
      tags,
      featuredImageUrl,
      imageUrls,
      category,
      isFeatured,
      status
    } = req.body;

    // Only admins can set featured articles or publish directly
    if (isFeatured && !req.user.isAdmin) {
      delete req.body.isFeatured;
    }
    if (status === 'published' && !req.user.isAdmin && req.user.role !== 'editor') {
      req.body.status = 'submitted'; // Regular members submit for review
    }

    Object.assign(article, req.body);
    await article.save();
    await article.populate('author', 'displayName profileImageUrl');

    res.json({
      message: 'Article updated successfully',
      article
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to update article',
      message: error.message
    });
  }
});

// Delete article
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const article = await MagazineArticle.findById(req.params.id);

    if (!article) {
      return res.status(404).json({
        error: 'Article not found',
        message: 'Article with the specified ID does not exist'
      });
    }

    // Check permissions
    const canDelete = req.user.isAdmin || 
                     req.user._id.toString() === article.author.toString();
    
    if (!canDelete) {
      return res.status(403).json({
        error: 'Permission denied',
        message: 'You can only delete your own articles'
      });
    }

    await MagazineArticle.findByIdAndDelete(req.params.id);

    res.json({
      message: 'Article deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to delete article',
      message: error.message
    });
  }
});

module.exports = router;