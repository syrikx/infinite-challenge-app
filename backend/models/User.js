const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true,
  },
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    minlength: 3,
    maxlength: 20,
  },
  displayName: {
    type: String,
    required: true,
    trim: true,
    minlength: 2,
    maxlength: 50,
  },
  password: {
    type: String,
    required: true,
    minlength: 8,
  },
  role: {
    type: String,
    enum: ['guest', 'pending', 'member', 'editor', 'moderator', 'admin'],
    default: 'pending',
  },
  isActive: {
    type: Boolean,
    default: true,
  },
  profileImageUrl: {
    type: String,
    default: null,
  },
  bio: {
    type: String,
    maxlength: 200,
    default: null,
  },
  reason: {
    type: String,
    maxlength: 200,
    default: null,
  },
  lastLoginAt: {
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
userSchema.pre('save', function(next) {
  this.updatedAt = new Date();
  next();
});

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Compare password method
userSchema.methods.comparePassword = async function(candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

// Transform output
userSchema.methods.toJSON = function() {
  const user = this.toObject();
  delete user.password;
  return user;
};

// Virtual properties
userSchema.virtual('canCreatePosts').get(function() {
  return ['admin', 'editor', 'member'].includes(this.role);
});

userSchema.virtual('canModerate').get(function() {
  return ['admin', 'moderator'].includes(this.role);
});

userSchema.virtual('isAdmin').get(function() {
  return this.role === 'admin';
});

// Ensure virtual fields are serialized
userSchema.set('toJSON', {
  virtuals: true,
});

module.exports = mongoose.model('User', userSchema);