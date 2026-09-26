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
    const users = await User.find({ role: 'user' }).lean();
    const totalUsers = users.length;
    
    const todayStart = new Date(new Date().setHours(0, 0, 0, 0));
    const activeToday = users.filter(u => u.lastPracticeDate && new Date(u.lastPracticeDate) >= todayStart).length;
    
    let totalAccuracySum = 0;
    let totalPointsSum = 0;
    let totalLevelSum = 0;
    let totalSessionsCount = 0;

    const chordCounts = {};

    users.forEach(u => {
      totalAccuracySum += (u.accuracy || 0);
      totalPointsSum += (u.totalPoints || 0);
      totalLevelSum += (u.currentLevel || 1);
      
      const sessions = Array.isArray(u.practiceSessions) ? u.practiceSessions : [];
      totalSessionsCount += sessions.length;

      // Tally chord practices from practiceSessions
      sessions.forEach(s => {
        if (s && s.chordPracticed) {
          const parts = s.chordPracticed.split(',').map(p => p.trim());
          parts.forEach(p => {
            if (p) {
              chordCounts[p] = (chordCounts[p] || 0) + 1;
            }
          });
        }
      });

      // Tally completedChords
      if (Array.isArray(u.completedChords)) {
        u.completedChords.forEach(c => {
          if (c && c.name) {
            const name = c.name.trim();
            chordCounts[name] = (chordCounts[name] || 0) + 1;
          }
        });
      }

      // Tally learningChords
      if (Array.isArray(u.learningChords)) {
        u.learningChords.forEach(lc => {
          if (lc && lc.name) {
            const name = lc.name.trim();
            chordCounts[name] = (chordCounts[name] || 0) + 1;
          }
        });
      }
    });

    const avgAccuracy = totalUsers > 0 ? Math.round(totalAccuracySum / totalUsers) : 0;
    const avgLevel = totalUsers > 0 ? (totalLevelSum / totalUsers).toFixed(1) : "1.0";
    const totalPoints = totalPointsSum.toLocaleString();

    // Most active users
    const sortedUsers = [...users].sort((a, b) => {
      const aSess = (a.practiceSessions || []).length;
      const bSess = (b.practiceSessions || []).length;
      if (bSess !== aSess) return bSess - aSess;
      return (b.totalPoints || 0) - (a.totalPoints || 0);
    });

    const mostActiveUsers = sortedUsers.slice(0, 3).map(u => ({
      name: u.username || 'User',
      level: `Level ${u.currentLevel || 1}`,
      sessions: `${(u.practiceSessions || []).length} sessions`
    }));

    if (mostActiveUsers.length === 0) {
      mostActiveUsers.push(
        { name: 'No users yet', level: 'Level 1', sessions: '0 sessions' }
      );
    }

    // Popular chords
    const sortedChords = Object.entries(chordCounts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3)
      .map(([chord, count]) => ({
        chord,
        practices: `${count} practice${count === 1 ? '' : 's'}`
      }));

    if (sortedChords.length === 0) {
      sortedChords.push(
        { chord: 'C Major', practices: '0 practices' },
        { chord: 'G Major', practices: '0 practices' },
        { chord: 'D Major', practices: '0 practices' }
      );
    }

    res.json({
      totalUsers,
      activeToday,
      avgAccuracy,
      totalSessions: totalSessionsCount,
      avgLevel,
      totalPoints,
      mostActiveUsers,
      popularChords: sortedChords
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
