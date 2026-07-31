// routes/authRoutes.js
const express = require('express');
const router = express.Router();
const User = require('../models/User');
const nodemailer = require('nodemailer');
const { checkAndAwardBadges } = require('../utils/badgeHelper');

// 1. REGISTER ROUTE
router.post('/register', async (req, res) => {
  const { username, email, password } = req.body;

  try {
    // Check if username OR email already exists in MongoDB
    const existingUser = await User.findOne({ 
      $or: [{ username }, { email }] 
    });
    
    if (existingUser) {
      return res.status(400).json({ 
        message: existingUser.username === username 
          ? 'Username is already taken' 
          : 'Email is already registered' 
      });
    }

    // Create a new user with plaintext password and default progress data
    const newUser = new User({
      username,
      email,
      password, // Plaintext as requested
      role: 'user',
      currentLevel: 1,
      totalPoints: 0,
      progressPercent: 0.0,
      nextLevelPoints: 1000,
      currentChord: 'C Major',
      accuracy: 0,
      streak: 0,
      chordsMastered: 0,

      // AUTOMATIC PROGRESS DATA FOR NEW USERS:
      completedChords: [], // Starts empty until they pass a chord
      learningChords: [
        { name: 'C Major', attempts: 0, progress: 0 },
        { name: 'G Major', attempts: 0, progress: 0 },
        { name: 'A Minor', attempts: 0, progress: 0 }
      ],
      practiceSessions: []
    });

    // Save to MongoDB
    await newUser.save();

    res.status(201).json({
      message: 'User registered successfully!',
      user: {
        _id: newUser._id,
        username: newUser.username,
        email: newUser.email,
        role: newUser.role,
        currentLevel: newUser.currentLevel,
        totalPoints: newUser.totalPoints,
        progressPercent: newUser.progressPercent,
        nextLevelPoints: newUser.nextLevelPoints,
        currentChord: newUser.currentChord,
        accuracy: newUser.accuracy,
        streak: newUser.streak,
        chordsMastered: newUser.chordsMastered,
        completedChords: newUser.completedChords,
        learningChords: newUser.learningChords,
        practiceSessions: newUser.practiceSessions,
      },
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error during registration', error: error.message });
  }
});

// 2. LOGIN ROUTE
router.post('/login', async (req, res) => {
  const { username, password } = req.body;

  try {
    const user = await User.findOne({ username });

    // Simple plaintext password check
    if (!user || user.password !== password) {
      return res.status(401).json({ message: 'Invalid username or password' });
    }

    // Return full user data including progress arrays for Flutter
    res.json({
      _id: user._id,
      username: user.username,
      email: user.email,
      role: user.role,
      currentLevel: user.currentLevel ?? 1,
      totalPoints: user.totalPoints ?? 0,
      progressPercent: user.progressPercent ?? 0.0,
      nextLevelPoints: user.nextLevelPoints ?? 1000,
      currentChord: user.currentChord ?? 'C Major',
      accuracy: user.accuracy ?? 0,
      streak: user.streak ?? 0,
      chordsMastered: user.chordsMastered ?? 0,
      completedChords: user.completedChords ?? [],
      learningChords: user.learningChords ?? [],
      practiceSessions: user.practiceSessions ?? [],
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// 3. FORGOT PASSWORD ROUTE
router.post('/forgot-password', async (req, res) => {
  const { email } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'No account found with that email address.' });
    }

    // Generate 6-digit code
    const resetToken = Math.floor(100000 + Math.random() * 900000).toString();
    
    user.resetPasswordToken = resetToken;
    user.resetPasswordExpires = Date.now() + 3600000; // Expires in 1 hour
    await user.save();

    // Nodemailer Transporter
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: 'joshuaroel0410@gmail.com', 
        pass: 'nzbxxamicnbrncuc',   
      },
    });

    const mailOptions = {
      from: '"ChordSense Support" <joshuaroel0410@gmail.com>',
      to: user.email,
      subject: 'Password Reset Code - ChordSense',
      html: `
        <div style="font-family: Arial, sans-serif; color: #1e293b; padding: 20px;">
          <h2>Password Reset Request</h2>
          <p>You requested to reset your password for ChordSense. Use the verification code below:</p>
          <h1 style="color: #9333ea; letter-spacing: 4px;">${resetToken}</h1>
          <p>This code will expire in 1 hour.</p>
        </div>
      `,
    };

    await transporter.sendMail(mailOptions);

    res.json({ message: 'Reset code sent to your email!' });
  } catch (error) {
    res.status(500).json({ message: 'Error sending email', error: error.message });
  }
});

// 4. RESET PASSWORD ROUTE
router.post('/reset-password', async (req, res) => {
  const { email, resetToken, newPassword } = req.body;

  try {
    // Find user with matching email, active token, and token not expired
    const user = await User.findOne({
      email,
      resetPasswordToken: resetToken,
      resetPasswordExpires: { $gt: Date.now() },
    });

    if (!user) {
      return res.status(400).json({ message: 'Invalid or expired verification code.' });
    }

    // Update password (plaintext) and clear reset token fields
    user.password = newPassword;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpires = undefined;
    await user.save();

    res.json({ message: 'Password reset successful! You can now log in.' });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// 5. GET LEADERBOARD ROUTE
// GET /api/auth/leaderboard
router.get('/leaderboard', async (req, res) => {
  try {
    const { sortBy } = req.query; // 'accuracy', 'xp', or 'sessions' sent from Flutter

    // Map Flutter sorting tabs to your User schema fields
    let sortField = 'accuracy';
    if (sortBy === 'xp') {
      sortField = 'totalPoints';
    } else if (sortBy === 'sessions') {
      sortField = 'practiceSessions';
    } else if (sortBy === 'accuracy') {
      sortField = 'accuracy';
    }

    // Query users: FILTER OUT admins using { role: { $ne: 'admin' } }
    const users = await User.find({ role: { $ne: 'admin' } })
      .select('username currentLevel totalPoints streak accuracy practiceSessions avatarAsset role')
      .sort({ [sortField]: -1 })
      .limit(50);

    // Format fields so Flutter receives exact properties
    const formattedLeaderboard = users.map((u) => ({
      _id: u._id,
      name: u.username,
      level: u.currentLevel ?? 1,
      xp: u.totalPoints ?? 0,
      days: u.streak ?? 0,
      accuracy: u.accuracy ?? 0,
      sessions: Array.isArray(u.practiceSessions) ? u.practiceSessions.length : (u.practiceSessions ?? 0),
      avatarAsset: u.avatarAsset ?? '',
    }));

    res.status(200).json(formattedLeaderboard);
  } catch (error) {
    console.error('Error fetching leaderboard:', error);
    res.status(500).json({ message: 'Server error fetching leaderboard' });
  }
});


// 6. GET USER PROFILE ROUTE
// GET User Profile (e.g., /api/user/profile/:id or /api/user/:id)
// GET /api/auth/profile/:id
router.get('/profile/:id', async (req, res) => {
  try {
    let user = await User.findById(req.params.id);
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // 👈 RUN BADGE CHECK & REASSIGN THE UPDATED USER
    user = await checkAndAwardBadges(user);

    res.json(user);
  } catch (err) {
    console.error('Error in profile route:', err);
    res.status(500).json({ error: err.message });
  }
});
module.exports = router;