const mongoose = require('mongoose');

const magazineArticleSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    maxlength: 100,
    trim: true,
  },
  content: {
    type: String,
    required: true,
    minlength: 10,
  },
  excerpt: {
    type: String,
    required: true,
    maxlength: 200,
    trim: true,
  },
  author: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  authorName: {
    type: String,
    required: true,
  },
  tags: [{
    type: String,
    trim: true,
    maxlength: 20,
  }],
  featuredImageUrl: {
    type: String,
    default: null,
  },
  imageUrls: [{
    type: String,
  }],
  category: {
    type: String,
    enum: ['general', 'study_abroad', 'visa', 'scholarship', 'language', 'life', 'career', 'university'],
    default: 'general',
  },
  status: {
    type: String,
    enum: ['draft', 'submitted', 'published', 'archived'],
    default: 'draft',
  },
  isFeatured: {
    type: Boolean,
    default: false,
  },
  viewCount: {
    type: Number,
    default: 0,
  },
  likeCount: {
    type: Number,
    default: 0,
  },
  publishedAt: {
    type: Date,
    default: null,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
});

// Update the updatedAt field before saving
magazineArticleSchema.pre('save', function(next) {
  this.updatedAt = new Date();
  next();
});

// Set publishedAt when status changes to published
magazineArticleSchema.pre('save', function(next) {
  if (this.isModified('status') && this.status === 'published' && !this.publishedAt) {
    this.publishedAt = new Date();
  }
  next();
});

// Index for better query performance
magazineArticleSchema.index({ status: 1, publishedAt: -1 });
magazineArticleSchema.index({ category: 1, status: 1 });
magazineArticleSchema.index({ author: 1 });
magazineArticleSchema.index({ tags: 1 });

module.exports = mongoose.model('MagazineArticle', magazineArticleSchema);