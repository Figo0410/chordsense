// routes/authRoutes.js
const express = require('express');
const router = express.Router();
const User = require('../models/User');

// routes/authRoutes.js
router.post('/login', async (req, res) => {
  const { username, password } = req.body;

  try {
    const user = await User.findOne({ username });

    if (!user || user.password !== password) {
      return res.status(401).json({ message: 'Invalid username or password' });
    }

    // Return real user data
    res.json({
      _id: user._id,
      username: user.username,
      role: user.role,
      currentLevel: user.currentLevel ?? 1,
      totalPoints: user.totalPoints ?? 0,
      progressPercent: user.progressPercent ?? 0.0,
      nextLevelPoints: user.nextLevelPoints ?? 1000,
      currentChord: user.currentChord ?? 'C Major',
      accuracy: user.accuracy ?? 0,
      streak: user.streak ?? 0,
      chordsMastered: user.chordsMastered ?? 0,
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;