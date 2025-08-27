const express = require('express');
const User = require('../models/User');
const { authenticateToken, isAdmin } = require('../middleware/auth');

const router = express.Router();

// Get pending users (admin only)
router.get('/pending', authenticateToken, isAdmin, async (req, res) => {
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

// Approve user (admin only)
router.put('/:userId/approve', authenticateToken, isAdmin, async (req, res) => {
  try {
    const { userId } = req.params;
    const { role = 'member' } = req.body;

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
router.delete('/:userId/reject', authenticateToken, isAdmin, async (req, res) => {
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
router.put('/:userId/role', authenticateToken, isAdmin, async (req, res) => {
  try {
    const { userId } = req.params;
    const { role } = req.body;

    const validRoles = ['member', 'editor', 'moderator', 'admin'];
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

    user.role = role;
    await user.save();

    res.json({
      message: `User role updated to: ${role}`,
      user: {
        id: user._id,
        displayName: user.displayName,
        email: user.email,
        role: user.role
      }
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to update user role',
      message: error.message
    });
  }
});

module.exports = router;