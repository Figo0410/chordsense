const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Song = require('../models/Song');
const LearningPath = require('../models/LearningPath');
const adminAuth = require('../middleware/adminAuth');

// Apply adminAuth to all routes in this file
router.use(adminAuth);

// GET /api/admin/stats - Aggregated dashboard metrics
router.get('/stats', async (req, res) => {
  try {
    const totalUsers = await User.countDocuments({ role: 'user' });
    const activeToday = await User.countDocuments({
      role: 'user',
      lastPracticeDate: { $gte: new Date(new Date().setHours(0, 0, 0, 0)) }
    });
    
    // Calculate Avg Accuracy across users
    const userStats = await User.aggregate([
      { $match: { role: 'user' } },
      { $group: { _id: null, avgAccuracy: { $avg: '$accuracy' } } }
    ]);
    const avgAccuracy = userStats.length > 0 ? userStats[0].avgAccuracy : 0;
    
    // Total Practice Sessions
    const sessionStats = await User.aggregate([
      { $match: { role: 'user' } },
      { $project: { sessionCount: { $size: { $ifNull: ["$practiceSessions", []] } } } },
      { $group: { _id: null, totalSessions: { $sum: "$sessionCount" } } }
    ]);
    const totalSessions = sessionStats.length > 0 ? sessionStats[0].totalSessions : 0;

    res.json({
      totalUsers,
      activeToday,
      avgAccuracy: Math.round(avgAccuracy),
      totalSessions
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// GET /api/admin/users - Get all users
router.get('/users', async (req, res) => {
  try {
    const users = await User.find({ role: 'user' });
    res.json(users);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// DELETE /api/admin/users/:id - Delete a user
router.delete('/users/:id', async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json({ message: 'User deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;
