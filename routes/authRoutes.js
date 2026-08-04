const express = require('express');
const router = express.Router();
const User = require('../models/User');
const nodemailer = require('nodemailer');
const { checkAndAwardBadges } = require('../utils/badgeHelper');

// Temporary in-memory store for registration OTPs
// Structure: { email: { username, email, password, code, expiresAt } }
const pendingRegistrations = new Map();

// Nodemailer Transporter
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'joshuaroel0410@gmail.com', 
    pass: 'nzbxxamicnbrncuc',   
  },
});

// 1. STEP 1: SEND REGISTER OTP ROUTE
router.post('/send-register-otp', async (req, res) => {
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

    // Generate 6-digit registration code
    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = Date.now() + 600000; // 10 minutes expiry

    // Save pending user details in memory until verified
    pendingRegistrations.set(email.toLowerCase(), {
      username,
      email,
      password,
      code: otpCode,
      expiresAt
    });

    const mailOptions = {
      from: '"ChordSense Support" <joshuaroel0410@gmail.com>',
      to: email,
      subject: 'Account Verification Code - ChordSense',
      html: `
        <div style="font-family: Arial, sans-serif; color: #1e293b; padding: 20px;">
          <h2>Verify Your Email</h2>
          <p>Thank you for signing up for ChordSense! Use the 6-digit code below to complete your registration:</p>
          <h1 style="color: #9333ea; letter-spacing: 4px;">${otpCode}</h1>
          <p>This code will expire in 10 minutes.</p>
        </div>
      `,
    };

    await transporter.sendMail(mailOptions);

    res.status(200).json({ message: 'Verification code sent to your email!' });
  } catch (error) {
    res.status(500).json({ message: 'Error sending verification email', error: error.message });
  }
});

// 2. STEP 2: VERIFY REGISTER OTP & CREATE ACCOUNT
router.post('/verify-register-otp', async (req, res) => {
  const { email, code } = req.body;

  try {
    const pending = pendingRegistrations.get(email.toLowerCase());

    if (!pending) {
      return res.status(400).json({ message: 'No registration request found or code expired.' });
    }

    if (Date.now() > pending.expiresAt) {
      pendingRegistrations.delete(email.toLowerCase());
      return res.status(400).json({ message: 'Verification code has expired. Please try registering again.' });
    }

    if (pending.code !== code) {
      return res.status(400).json({ message: 'Invalid verification code.' });
    }

    // Code is valid! Create official user in MongoDB
    const newUser = new User({
      username: pending.username,
      email: pending.email,
      password: pending.password, // Plaintext as requested
      role: 'user',
      currentLevel: 1,
      totalPoints: 0,
      progressPercent: 0.0,
      nextLevelPoints: 1000,
      currentChord: 'C Major',
      accuracy: 0,
      streak: 0,
      chordsMastered: 0,
      hasCompletedTuner: false, // Default for new users

      completedChords: [],
      learningChords: [
        { name: 'C Major', attempts: 0, progress: 0 },
        { name: 'G Major', attempts: 0, progress: 0 },
        { name: 'A Minor', attempts: 0, progress: 0 }
      ],
      practiceSessions: []
    });

    await newUser.save();

    // Clean up temporary record
    pendingRegistrations.delete(email.toLowerCase());

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
        hasCompletedTuner: newUser.hasCompletedTuner,
        completedChords: newUser.completedChords,
        learningChords: newUser.learningChords,
        practiceSessions: newUser.practiceSessions,
      },
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error during verification', error: error.message });
  }
});

// 3. LEGACY REGISTER ROUTE (DIRECT REGISTER BACKUP)
router.post('/register', async (req, res) => {
  const { username, email, password } = req.body;

  try {
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

    const newUser = new User({
      username,
      email,
      password,
      role: 'user',
      currentLevel: 1,
      totalPoints: 0,
      progressPercent: 0.0,
      nextLevelPoints: 1000,
      currentChord: 'C Major',
      accuracy: 0,
      streak: 0,
      chordsMastered: 0,
      hasCompletedTuner: false,

      completedChords: [],
      learningChords: [
        { name: 'C Major', attempts: 0, progress: 0 },
        { name: 'G Major', attempts: 0, progress: 0 },
        { name: 'A Minor', attempts: 0, progress: 0 }
      ],
      practiceSessions: []
    });

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
        hasCompletedTuner: newUser.hasCompletedTuner,
        completedChords: newUser.completedChords,
        learningChords: newUser.learningChords,
        practiceSessions: newUser.practiceSessions,
      },
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error during registration', error: error.message });
  }
});

// 4. LOGIN ROUTE
router.post('/login', async (req, res) => {
  const { username, password } = req.body;

  try {
    const user = await User.findOne({ username });

    if (!user || user.password !== password) {
      return res.status(401).json({ message: 'Invalid username or password' });
    }

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
      hasCompletedTuner: user.hasCompletedTuner ?? false,
      completedChords: user.completedChords ?? [],
      learningChords: user.learningChords ?? [],
      practiceSessions: user.practiceSessions ?? [],
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// 5. FORGOT PASSWORD ROUTE
router.post('/forgot-password', async (req, res) => {
  const { email } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'No account found with that email address.' });
    }

    const resetToken = Math.floor(100000 + Math.random() * 900000).toString();
    
    user.resetPasswordToken = resetToken;
    user.resetPasswordExpires = Date.now() + 3600000;
    await user.save();

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

// 6. RESET PASSWORD ROUTE
router.post('/reset-password', async (req, res) => {
  const { email, resetToken, newPassword } = req.body;

  try {
    const user = await User.findOne({
      email,
      resetPasswordToken: resetToken,
      resetPasswordExpires: { $gt: Date.now() },
    });

    if (!user) {
      return res.status(400).json({ message: 'Invalid or expired verification code.' });
    }

    user.password = newPassword;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpires = undefined;
    await user.save();

    res.json({ message: 'Password reset successful! You can now log in.' });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// 7. GET LEADERBOARD ROUTE
router.get('/leaderboard', async (req, res) => {
  try {
    const { sortBy } = req.query;

    let sortField = 'accuracy';
    if (sortBy === 'xp') {
      sortField = 'totalPoints';
    } else if (sortBy === 'sessions') {
      sortField = 'practiceSessions';
    } else if (sortBy === 'accuracy') {
      sortField = 'accuracy';
    }

    const users = await User.find({ role: { $ne: 'admin' } })
      .select('username currentLevel totalPoints streak accuracy practiceSessions avatarAsset role')
      .sort({ [sortField]: -1 })
      .limit(50);

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

// 8. GET USER PROFILE ROUTE
router.get('/profile/:id', async (req, res) => {
  try {
    let user = await User.findById(req.params.id);
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    user = await checkAndAwardBadges(user);

    res.json(user);
  } catch (err) {
    console.error('Error in profile route:', err);
    res.status(500).error({ error: err.message });
  }
});

// 9. PATCH USER TUNER STATUS ROUTE
router.patch('/user/:id/tuner-status', async (req, res) => {
  try {
    const { hasCompletedTuner } = req.body;
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { hasCompletedTuner },
      { new: true }
    );
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;