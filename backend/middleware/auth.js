const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Verify JWT token
const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      return res.status(401).json({
        error: 'Access token required',
        message: 'Please provide a valid access token'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.userId).select('-password');
    
    if (!user) {
      return res.status(401).json({
        error: 'Invalid token',
        message: 'User not found'
      });
    }

    if (!user.isActive) {
      return res.status(401).json({
        error: 'Account deactivated',
        message: 'Your account has been deactivated'
      });
    }

    req.user = user;
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        error: 'Invalid token',
        message: 'Please provide a valid access token'
      });
    } else if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        error: 'Token expired',
        message: 'Your session has expired. Please login again'
      });
    }
    
    res.status(500).json({
      error: 'Authentication error',
      message: error.message
    });
  }
};

// Check if user has required role (deprecated - use requirePermission instead)
const requireRole = (roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        error: 'Authentication required',
        message: 'Please login first'
      });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        error: 'Insufficient permissions',
        message: `This action requires one of the following roles: ${roles.join(', ')}`
      });
    }

    next();
  };
};

// Check if user has required permission (NEW - 권한 기반 체크)
const requirePermission = (permission) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        error: 'Authentication required',
        message: 'Please login first'
      });
    }

    if (!req.user.hasPermission(permission)) {
      return res.status(403).json({
        error: 'Insufficient permissions',
        message: `This action requires ${permission} permission`
      });
    }

    next();
  };
};

// Check if user has minimum role level (NEW - 레벨 기반 체크)
const requireRoleLevel = (minimumLevel) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        error: 'Authentication required',
        message: 'Please login first'
      });
    }

    if (!req.user.hasRoleLevel(minimumLevel)) {
      const levelName = typeof minimumLevel === 'string' ? minimumLevel : `level ${minimumLevel}`;
      return res.status(403).json({
        error: 'Insufficient permissions',
        message: `This action requires ${levelName} or higher`
      });
    }

    next();
  };
};

// Specific permission middlewares
const canReadMagazine = requirePermission('READ_MAGAZINE');
const canWriteMagazine = requirePermission('WRITE_MAGAZINE');
const canEditMagazine = requirePermission('EDIT_MAGAZINE');
const canDeleteMagazine = requirePermission('DELETE_MAGAZINE');

const canReadCommunity = requirePermission('READ_COMMUNITY');
const canWriteCommunity = requirePermission('WRITE_COMMUNITY');
const canEditCommunity = requirePermission('EDIT_COMMUNITY');
const canDeleteCommunity = requirePermission('DELETE_COMMUNITY');
const canModerateCommunity = requirePermission('MODERATE_COMMUNITY');

const canManageUsers = requirePermission('MANAGE_USERS');
const canChangeRoles = requirePermission('CHANGE_ROLES');
const canViewAnalytics = requirePermission('VIEW_ANALYTICS');
const canSystemSettings = requirePermission('SYSTEM_SETTINGS');

// 기존 호환성을 위한 미들웨어 (deprecated - 새로운 권한 시스템 사용 권장)
const canCreatePosts = (req, res, next) => {
  if (!req.user || !req.user.hasPermission('WRITE_COMMUNITY')) {
    return res.status(403).json({
      error: 'Insufficient permissions',
      message: 'You need user privileges or higher to create posts'
    });
  }
  next();
};

const canModerate = (req, res, next) => {
  if (!req.user || !req.user.hasPermission('MODERATE_COMMUNITY')) {
    return res.status(403).json({
      error: 'Insufficient permissions',
      message: 'You need operator privileges or higher for this action'
    });
  }
  next();
};

const isAdmin = (req, res, next) => {
  if (!req.user || req.user.role !== 'admin') {
    return res.status(403).json({
      error: 'Admin access required',
      message: 'This action requires administrator privileges'
    });
  }
  next();
};

// 본인 컨텐츠만 수정/삭제 가능하도록 체크
const isOwnerOrModerator = (getResourceUserId) => {
  return async (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        error: 'Authentication required',
        message: 'Please login first'
      });
    }

    try {
      const resourceUserId = await getResourceUserId(req);
      
      // 본인이거나 모더레이션 권한이 있으면 허용
      if (req.user._id.toString() === resourceUserId.toString() || 
          req.user.hasPermission('MODERATE_COMMUNITY')) {
        next();
      } else {
        return res.status(403).json({
          error: 'Insufficient permissions',
          message: 'You can only modify your own content'
        });
      }
    } catch (error) {
      return res.status(500).json({
        error: 'Permission check error',
        message: error.message
      });
    }
  };
};

module.exports = {
  // 기본 인증
  authenticateToken,
  
  // 새로운 권한 시스템 (권장)
  requirePermission,
  requireRoleLevel,
  
  // 매거진 권한
  canReadMagazine,
  canWriteMagazine,
  canEditMagazine,
  canDeleteMagazine,
  
  // 커뮤니티 권한
  canReadCommunity,
  canWriteCommunity,
  canEditCommunity,
  canDeleteCommunity,
  canModerateCommunity,
  
  // 관리 권한
  canManageUsers,
  canChangeRoles,
  canViewAnalytics,
  canSystemSettings,
  
  // 소유권 체크
  isOwnerOrModerator,
  
  // 기존 호환성 (deprecated)
  requireRole,
  canCreatePosts,
  canModerate,
  isAdmin
};