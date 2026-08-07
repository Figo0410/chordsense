const express = require('express');
const router = express.Router();
const User = require('../models/User');
const LearningPath = require('../models/LearningPath');
const nodemailer = require('nodemailer');
const { checkAndAwardBadges } = require('../utils/badgeHelper');

// Temporary in-memory store for registration OTPs
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

    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = Date.now() + 600000;

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

    const newUser = new User({
      username: pending.username,
      email: pending.email,
      password: pending.password,
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
      completedLevels: [],
      learningChords: [
        { name: 'C Major', attempts: 0, progress: 0 },
        { name: 'G Major', attempts: 0, progress: 0 },
        { name: 'A Minor', attempts: 0, progress: 0 }
      ],
      practiceSessions: []
    });

    await newUser.save();

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
        completedLevels: newUser.completedLevels,
        learningChords: newUser.learningChords,
        practiceSessions: newUser.practiceSessions,
      },
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error during verification', error: error.message });
  }
});

// 3. LEGACY REGISTER ROUTE
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
      completedLevels: [],
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
        completedLevels: newUser.completedLevels,
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
      completedLevels: user.completedLevels ?? [],
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
    res.status(500).json({ error: err.message });
  }
});

// GET USER PROFILE / BACKEND SYNC ROUTE
router.get('/user/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: err.message });
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

// 10. PATCH USER PROGRESS & LEARNING PATH SYNC ROUTE
router.patch('/user/:id/progress', async (req, res) => {
  try {
    const { 
      levelId, 
      levelNumber, 
      pointsEarned, 
      accuracy, 
      completed, 
      completedLevel, 
      chordsCompleted, 
      chordPracticed,
      currentLevel 
    } = req.body;

    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: 'User not found' });

    const targetLevelNum = levelNumber || levelId || (completedLevel && completedLevel.levelNumber);

    if (pointsEarned) {
      user.totalPoints = (user.totalPoints || 0) + pointsEarned;
    }
    if (accuracy !== undefined) user.accuracy = accuracy;
    if (chordPracticed) user.currentChord = chordPracticed;

    // Handle completed chords
    const chordsToAdd = chordsCompleted || (chordPracticed ? chordPracticed.split(',').map(c => c.trim()) : []);
    chordsToAdd.forEach((chord) => {
      if (chord && !user.completedChords.includes(chord)) {
        user.completedChords.push(chord);
      }
    });
    user.chordsMastered = user.completedChords.length;

    // Force completion flag if level completion object or targetLevelNum is present
    const isCompleted = completed === true || !!completedLevel || (targetLevelNum && accuracy !== undefined);

    if (isCompleted && targetLevelNum) {
      if (!user.completedLevels) user.completedLevels = [];
      const existingIdx = user.completedLevels.findIndex((cl) => cl.levelNumber === targetLevelNum);
      
      const levelObj = {
        levelNumber: targetLevelNum,
        progress: 1.0,
        accuracy: accuracy || (user.completedLevels[existingIdx] && user.completedLevels[existingIdx].accuracy) || 100,
      };

      if (existingIdx !== -1) {
        user.completedLevels[existingIdx] = levelObj;
      } else {
        user.completedLevels.push(levelObj);
      }

      const nextLevel = currentLevel || (targetLevelNum + 1);
      if (user.currentLevel <= targetLevelNum) {
        user.currentLevel = nextLevel;
      }

      const nextLevelData = await LearningPath.findOne({ levelNumber: user.currentLevel });
      if (nextLevelData) {
        user.nextLevelPoints = nextLevelData.requiredPoints;
      }
    }

    if (user.nextLevelPoints > 0) {
      user.progressPercent = Math.min(100.0, (user.totalPoints / user.nextLevelPoints) * 100);
    }

    await user.save();
    res.status(200).json(user);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/practice/save-session
router.post('/save-session', async (req, res) => {
  try {
    const { userId, levelId, chordPracticed, totalAttempts, correctAttempts, incorrectAttempts, accuracy, pointsEarned, duration } = req.body;

    const isCompleted = correctAttempts > 0;
    const sessionData = {
      levelId,
      chordPracticed,
      date: new Date(),
      totalAttempts,
      correctAttempts,
      incorrectAttempts,
      accuracy,
      pointsEarned,
      duration,
      completionStatus: isCompleted ? "Completed" : "Incomplete"
    };

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: "User not found" });

    user.practiceSessions.push(sessionData);
    user.totalPoints = (user.totalPoints || 0) + (pointsEarned || 0);
    user.accuracy = accuracy;
    user.currentChord = chordPracticed;

    if (isCompleted && chordPracticed) {
      const chordArray = chordPracticed.split(',').map((c) => c.trim());
      chordArray.forEach((chord) => {
        if (!user.completedChords.includes(chord)) {
          user.completedChords.push(chord);
        }
      });
      user.chordsMastered = user.completedChords.length;

      if (levelId) {
        if (!user.completedLevels) user.completedLevels = [];
        const existingIdx = user.completedLevels.findIndex((cl) => cl.levelNumber === levelId);
        if (existingIdx !== -1) {
          user.completedLevels[existingIdx] = {
            levelNumber: levelId,
            progress: 1.0,
            accuracy: accuracy || user.completedLevels[existingIdx].accuracy || 100,
          };
        } else {
          user.completedLevels.push({
            levelNumber: levelId,
            progress: 1.0,
            accuracy: accuracy || 100,
          });
        }

        if (user.currentLevel <= levelId) {
          user.currentLevel = levelId + 1;
        }
      }
    }

    await user.save();
    res.status(200).json({ message: "Session recorded successfully", user });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;