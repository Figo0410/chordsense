// routes/authRoutes.js
const express = require('express');
const router = express.Router();
const User = require('../models/User');
const nodemailer = require('nodemailer');

// 1. REGISTER ROUTE
router.post('/register', async (req, res) => {
  const { username, email, password } = req.body;

  try {
    // Check if the user already exists in MongoDB
    const existingUser = await User.findOne({ username });
    if (existingUser) {
      return res.status(400).json({ message: 'Username is already taken' });
    }

    // Create a new user with default initial stats
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
    });

    // Save to MongoDB
    await newUser.save();

    res.status(201).json({
      message: 'User registered successfully!',
      user: {
        _id: newUser._id,
        username: newUser.username,
        role: newUser.role,
        currentLevel: newUser.currentLevel,
        totalPoints: newUser.totalPoints,
        progressPercent: newUser.progressPercent,
        nextLevelPoints: newUser.nextLevelPoints,
        currentChord: newUser.currentChord,
        accuracy: newUser.accuracy,
        streak: newUser.streak,
        chordsMastered: newUser.chordsMastered,
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
        user: 'joshuaroel0410@gmail.com', // Replace with your Gmail
        pass: 'nzbxxamicnbrncuc',   // Replace with your Google App Password
      },
    });

    const mailOptions = {
      from: '"ChordSense Support" <YOUR_GMAIL_ADDRESS@gmail.com>',
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

// RESET PASSWORD ROUTE
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

    // Update password and clear reset token fields
    user.password = newPassword;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpires = undefined;
    await user.save();

    res.json({ message: 'Password reset successful! You can now log in.' });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;