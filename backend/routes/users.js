const express = require('express');
const User = require('../models/User');
const { authenticateToken, canManageUsers, canChangeRoles } = require('../middleware/auth');

const router = express.Router();

// Get all users (admin only)
router.get('/', authenticateToken, canManageUsers, async (req, res) => {
  try {
    const { role, search, page = 1, limit = 50 } = req.query;
    const skip = (page - 1) * limit;
    
    // Build query
    let query = {};
    if (role) {
      query.role = role;
    }
    if (search) {
      query.$or = [
        { displayName: { $regex: search, $options: 'i' } },
        { username: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } }
      ];
    }

    const users = await User.find(query)
      .select('-password')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await User.countDocuments(query);

    res.json({
      users,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / limit),
        total,
        hasNext: page * limit < total,
        hasPrev: page > 1
      }
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch users',
      message: error.message
    });
  }
});

// Get pending users (admin only) - 기존 호환성
router.get('/pending', authenticateToken, canManageUsers, async (req, res) => {
  try {
    const pendingUsers = await User.find({ role: 'pending' })
      .select('-password')
      .sort({ createdAt: -1 });

    res.json({
      users: pendingUsers,
      total: pendingUsers.length
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch pending users',
      message: error.message
    });
  }
});

// Approve user with specific role (admin only)
router.put('/:userId/approve', authenticateToken, canChangeRoles, async (req, res) => {
  try {
    const { userId } = req.params;
    const { role = 'free_user' } = req.body;

    // Get valid roles from User model
    const validRoles = Object.keys(User.getRoleHierarchy()).filter(r => r !== 'pending');
    
    if (!validRoles.includes(role)) {
      return res.status(400).json({
        error: 'Invalid role',
        message: `Role must be one of: ${validRoles.join(', ')}`
      });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        error: 'User not found',
        message: 'User with the specified ID does not exist'
      });
    }

    if (user.role !== 'pending') {
      return res.status(400).json({
        error: 'User already approved',
        message: 'User is already approved and active'
      });
    }

    user.role = role;
    await user.save();

    res.json({
      message: `User approved with role: ${role}`,
      user: {
        id: user._id,
        displayName: user.displayName,
        email: user.email,
        role: user.role,
        permissions: user.permissions,
        roleLevel: user.roleLevel
      }
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to approve user',
      message: error.message
    });
  }
});

// 기존 approve 엔드포인트도 유지 (호환성)
router.put('/:userId/approve-simple', authenticateToken, canChangeRoles, async (req, res) => {
  try {
    const { userId } = req.params;
    const { role = 'free_user' } = req.body;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        error: 'User not found',
        message: 'User with the specified ID does not exist'
      });
    }

    user.role = role;
    await user.save();

    res.json({
      message: `User approved with role: ${role}`,
      user: {
        id: user._id,
        displayName: user.displayName,
        email: user.email,
        role: user.role
      }
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to approve user',
      message: error.message
    });
  }
});

// Reject user (admin only)
router.delete('/:userId/reject', authenticateToken, canManageUsers, async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        error: 'User not found',
        message: 'User with the specified ID does not exist'
      });
    }

    await User.findByIdAndDelete(userId);

    res.json({
      message: 'User registration rejected and removed',
      user: {
        id: user._id,
        displayName: user.displayName,
        email: user.email
      }
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to reject user',
      message: error.message
    });
  }
});

// Change user role (admin only)
router.put('/:userId/role', authenticateToken, canChangeRoles, async (req, res) => {
  try {
    const { userId } = req.params;
    const { role } = req.body;

    // Get valid roles from User model
    const validRoles = Object.keys(User.getRoleHierarchy());
    
    if (!validRoles.includes(role)) {
      return res.status(400).json({
        error: 'Invalid role',
        message: `Role must be one of: ${validRoles.join(', ')}`
      });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        error: 'User not found',
        message: 'User with the specified ID does not exist'
      });
    }

    // 본인의 관리자 권한은 제거할 수 없음
    if (user._id.toString() === req.user._id.toString() && user.role === 'admin' && role !== 'admin') {
      return res.status(400).json({
        error: 'Cannot demote yourself',
        message: 'You cannot remove your own admin privileges'
      });
    }

    const oldRole = user.role;
    user.role = role;
    await user.save();

    res.json({
      message: `User role updated from ${oldRole} to ${role}`,
      user: {
        id: user._id,
        displayName: user.displayName,
        email: user.email,
        role: user.role,
        permissions: user.permissions,
        roleLevel: user.roleLevel
      }
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to update user role',
      message: error.message
    });
  }
});

// Get role hierarchy (admin only) - 새로운 엔드포인트
router.get('/roles', authenticateToken, canManageUsers, async (req, res) => {
  try {
    const roleHierarchy = User.getRoleHierarchy();
    const permissions = User.getPermissions();
    
    res.json({
      roles: roleHierarchy,
      permissions
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch role information',
      message: error.message
    });
  }
});

module.exports = router;