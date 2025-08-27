const express = require('express');
const CommunityPost = require('../models/CommunityPost');
const { authenticateToken, canCreatePosts, canModerate } = require('../middleware/auth');

const router = express.Router();

// Get posts
router.get('/', async (req, res) => {
  try {
    const { page = 1, limit = 20, type, search } = req.query;
    const skip = (page - 1) * limit;

    let query = { 
      status: 'active',
      parentPost: null // Only get main posts, not replies
    };
    
    if (type && type !== 'all') {
      query.type = type;
    }

    if (search) {
      query.$or = [
        { title: { $regex: search, $options: 'i' } },
        { content: { $regex: search, $options: 'i' } },
        { tags: { $in: [new RegExp(search, 'i')] } }
      ];
    }

    const posts = await CommunityPost.find(query)
      .populate('author', 'displayName profileImageUrl')
      .sort({ isPinned: -1, createdAt: -1 })
      .limit(parseInt(limit))
      .skip(skip);

    const total = await CommunityPost.countDocuments(query);

    res.json({
      posts,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / limit),
        totalPosts: total,
        hasNext: skip + posts.length < total,
        hasPrev: page > 1
      }
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch posts',
      message: error.message
    });
  }
});

// Get single post with replies
router.get('/:id', async (req, res) => {
  try {
    const post = await CommunityPost.findById(req.params.id)
      .populate('author', 'displayName profileImageUrl bio');

    if (!post) {
      return res.status(404).json({
        error: 'Post not found',
        message: 'Post with the specified ID does not exist'
      });
    }

    // Get replies
    const replies = await CommunityPost.find({ 
      parentPost: req.params.id,
      status: 'active'
    })
    .populate('author', 'displayName profileImageUrl')
    .sort({ createdAt: 1 });

    // Increment view count
    post.viewCount += 1;
    await post.save();

    res.json({ 
      post,
      replies 
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch post',
      message: error.message
    });
  }
});

// Create new post
router.post('/', authenticateToken, canCreatePosts, async (req, res) => {
  try {
    const {
      title,
      content,
      tags = [],
      imageUrls = [],
      type = 'discussion',
      parentPost = null
    } = req.body;

    const post = new CommunityPost({
      title,
      content,
      author: req.user._id,
      authorName: req.user.displayName,
      tags,
      imageUrls,
      type,
      parentPost
    });

    await post.save();

    // If this is a reply, increment reply count of parent post
    if (parentPost) {
      await CommunityPost.findByIdAndUpdate(
        parentPost,
        { $inc: { replyCount: 1 } }
      );
    }

    await post.populate('author', 'displayName profileImageUrl');

    res.status(201).json({
      message: parentPost ? 'Reply created successfully' : 'Post created successfully',
      post
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to create post',
      message: error.message
    });
  }
});

// Update post
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    const post = await CommunityPost.findById(req.params.id);

    if (!post) {
      return res.status(404).json({
        error: 'Post not found',
        message: 'Post with the specified ID does not exist'
      });
    }

    // Check permissions
    const canEdit = req.user.canModerate || 
                   req.user._id.toString() === post.author.toString();
    
    if (!canEdit) {
      return res.status(403).json({
        error: 'Permission denied',
        message: 'You can only edit your own posts'
      });
    }

    const { title, content, tags, imageUrls, isPinned, isLocked } = req.body;

    // Only moderators can pin/lock posts
    if ((isPinned !== undefined || isLocked !== undefined) && !req.user.canModerate) {
      return res.status(403).json({
        error: 'Permission denied',
        message: 'Only moderators can pin or lock posts'
      });
    }

    Object.assign(post, req.body);
    await post.save();
    await post.populate('author', 'displayName profileImageUrl');

    res.json({
      message: 'Post updated successfully',
      post
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to update post',
      message: error.message
    });
  }
});

// Delete post
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const post = await CommunityPost.findById(req.params.id);

    if (!post) {
      return res.status(404).json({
        error: 'Post not found',
        message: 'Post with the specified ID does not exist'
      });
    }

    // Check permissions
    const canDelete = req.user.canModerate || 
                     req.user._id.toString() === post.author.toString();
    
    if (!canDelete) {
      return res.status(403).json({
        error: 'Permission denied',
        message: 'You can only delete your own posts'
      });
    }

    // If deleting a reply, decrement parent reply count
    if (post.parentPost) {
      await CommunityPost.findByIdAndUpdate(
        post.parentPost,
        { $inc: { replyCount: -1 } }
      );
    }

    await CommunityPost.findByIdAndDelete(req.params.id);

    res.json({
      message: 'Post deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to delete post',
      message: error.message
    });
  }
});

module.exports = router;