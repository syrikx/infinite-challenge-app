const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

// 권한 레벨 정의 (숫자가 높을수록 높은 권한)
const ROLE_LEVELS = {
  'pending': 0,      // 승인 대기
  'free_user': 1,    // 무료사용자 - 매거진 및 커뮤니티 보기만 가능
  'user': 2,         // 사용자 - 커뮤니티 쓰기 가능
  'operator': 3,     // 운영자 - 매거진 작성, 수정 가능
  'admin': 4         // 관리자 - 모든 기능과 권한 변경 가능
};

// 권한별 기능 설정 (향후 쉽게 변경 가능)
const PERMISSIONS = {
  // 매거진 권한
  READ_MAGAZINE: ['free_user', 'user', 'operator', 'admin'],
  WRITE_MAGAZINE: ['operator', 'admin'],
  EDIT_MAGAZINE: ['operator', 'admin'],
  DELETE_MAGAZINE: ['admin'],
  
  // 커뮤니티 권한
  READ_COMMUNITY: ['free_user', 'user', 'operator', 'admin'],
  WRITE_COMMUNITY: ['user', 'operator', 'admin'],
  EDIT_COMMUNITY: ['user', 'operator', 'admin'], // 본인 글만
  DELETE_COMMUNITY: ['user', 'operator', 'admin'], // 본인 글만
  MODERATE_COMMUNITY: ['operator', 'admin'],
  
  // 관리 권한
  MANAGE_USERS: ['admin'],
  CHANGE_ROLES: ['admin'],
  VIEW_ANALYTICS: ['operator', 'admin'],
  SYSTEM_SETTINGS: ['admin']
};

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
    enum: Object.keys(ROLE_LEVELS),
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

// 권한 체크 메소드
userSchema.methods.hasPermission = function(permission) {
  const allowedRoles = PERMISSIONS[permission];
  return allowedRoles && allowedRoles.includes(this.role);
};

// 역할 레벨 비교 메소드
userSchema.methods.hasRoleLevel = function(requiredLevel) {
  const userLevel = ROLE_LEVELS[this.role] || 0;
  const required = typeof requiredLevel === 'string' ? ROLE_LEVELS[requiredLevel] : requiredLevel;
  return userLevel >= required;
};

// Transform output
userSchema.methods.toJSON = function() {
  const user = this.toObject();
  delete user.password;
  
  // 권한 정보 추가
  user.permissions = {
    canReadMagazine: this.hasPermission('READ_MAGAZINE'),
    canWriteMagazine: this.hasPermission('WRITE_MAGAZINE'),
    canEditMagazine: this.hasPermission('EDIT_MAGAZINE'),
    canDeleteMagazine: this.hasPermission('DELETE_MAGAZINE'),
    
    canReadCommunity: this.hasPermission('READ_COMMUNITY'),
    canWriteCommunity: this.hasPermission('WRITE_COMMUNITY'),
    canEditCommunity: this.hasPermission('EDIT_COMMUNITY'),
    canDeleteCommunity: this.hasPermission('DELETE_COMMUNITY'),
    canModerateCommunity: this.hasPermission('MODERATE_COMMUNITY'),
    
    canManageUsers: this.hasPermission('MANAGE_USERS'),
    canChangeRoles: this.hasPermission('CHANGE_ROLES'),
    canViewAnalytics: this.hasPermission('VIEW_ANALYTICS'),
    canSystemSettings: this.hasPermission('SYSTEM_SETTINGS')
  };
  
  user.roleLevel = ROLE_LEVELS[this.role] || 0;
  
  return user;
};

// 기존 호환성을 위한 Virtual properties (deprecated - permissions 사용 권장)
userSchema.virtual('canCreatePosts').get(function() {
  return this.hasPermission('WRITE_COMMUNITY');
});

userSchema.virtual('canModerate').get(function() {
  return this.hasPermission('MODERATE_COMMUNITY');
});

userSchema.virtual('isAdmin').get(function() {
  return this.role === 'admin';
});

// Static methods for role management
userSchema.statics.getRoleHierarchy = function() {
  return ROLE_LEVELS;
};

userSchema.statics.getPermissions = function() {
  return PERMISSIONS;
};

userSchema.statics.updatePermissions = function(newPermissions) {
  Object.assign(PERMISSIONS, newPermissions);
};

// Ensure virtual fields are serialized
userSchema.set('toJSON', {
  virtuals: true,
});

module.exports = mongoose.model('User', userSchema);