const mongoose = require('mongoose');

const communityPostSchema = new mongoose.Schema({
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
  imageUrls: [{
    type: String,
  }],
  type: {
    type: String,
    enum: ['discussion', 'question', 'news', 'help', 'showcase'],
    default: 'discussion',
  },
  status: {
    type: String,
    enum: ['active', 'hidden', 'deleted', 'reported'],
    default: 'active',
  },
  isPinned: {
    type: Boolean,
    default: false,
  },
  isLocked: {
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
  replyCount: {
    type: Number,
    default: 0,
  },
  parentPost: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'CommunityPost',
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
communityPostSchema.pre('save', function(next) {
  this.updatedAt = new Date();
  next();
});

// Virtual property to check if it's a reply
communityPostSchema.virtual('isReply').get(function() {
  return this.parentPost != null;
});

// Index for better query performance
communityPostSchema.index({ status: 1, isPinned: -1, createdAt: -1 });
communityPostSchema.index({ type: 1, status: 1 });
communityPostSchema.index({ author: 1 });
communityPostSchema.index({ parentPost: 1 });
communityPostSchema.index({ tags: 1 });

// Ensure virtual fields are serialized
communityPostSchema.set('toJSON', {
  virtuals: true,
});

module.exports = mongoose.model('CommunityPost', communityPostSchema);