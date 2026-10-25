const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const userSchema = new mongoose.Schema({
  username: { 
    type: String, 
    required: true, 
    unique: true 
  },
  email: { 
    type: String, 
    required: true, 
    unique: true 
  },
  password: { 
    type: String, 
    required: true 
  },
  role: { 
    type: String, 
    enum: ['user', 'admin'],
    default: 'user' 
  },
  currentLevel: { 
    type: Number, 
    default: 1 
  },
  totalPoints: { 
    type: Number, 
    default: 0 
  },
  progressPercent: { 
    type: Number, 
    default: 0.0 
  },
  nextLevelPoints: { 
    type: Number, 
    default: 1000 
  },
  currentChord: { 
    type: String, 
    default: 'C Major' 
  },
  accuracy: { 
    type: Number, 
    default: 0 
  },
  streak: { 
    type: Number, 
    default: 0 
  },
  lastPracticeDate: {
    type: Date,
    default: null
  },
  chordsMastered: { 
    type: Number, 
    default: 0 
  },
  
  // Real data flag to mark tuner completion state
  hasCompletedTuner: {
    type: Boolean,
    default: false
  },

  // Settings & Notification Preferences
  language: {
    type: String,
    default: 'English'
  },
  notificationPreferences: {
    practiceReminders: { type: Boolean, default: true },
    achievementsNotif: { type: Boolean, default: true },
    weeklyReportNotif: { type: Boolean, default: false },
    newSongsNotif: { type: Boolean, default: true },
    streakAlertsNotif: { type: Boolean, default: true }
  },

  // Array to track unlocked badge IDs for automatic point rewards
  unlockedBadges: { 
    type: [String], 
    default: [] 
  },

  // Detailed tracking for earned badges with timestamps
  badgeHistory: [{
    badgeId: { type: String, required: true },
    unlockedAt: { type: Date, default: Date.now },
    pointsEarned: { type: Number, default: 0 }
  }],

  // TRACK REAL COMPLETED LEVELS WITH ACCURACY & PROGRESS
  completedLevels: [{
    levelNumber: Number,
    progress: Number, // e.g. 1.0 for completed, 0.5 for 50%
    accuracy: Number,
    completedAt: { type: Date, default: Date.now }
  }],

  // ARRAYS MATCHING FLUTTER UI:
  completedChords: [{
    name: String,
    date: String,
    accuracy: Number
  }],
  learningChords: [{
    name: String,
    attempts: Number,
    progress: Number
  }],
  practiceSessions: [{
    sessionId: String,
    day: String,
    date: String,
    duration: String,
    accuracy: Number,
    chordsCount: Number,
    createdAt: { type: Date, default: Date.now }
  }],

  // Song practice tracking
  favoriteSongs: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Song'
  }],

  // Fields needed for Password Reset:
  resetPasswordToken: String,
  resetPasswordExpires: Date,

  // Account Status ('Active' or 'Disabled')
  accountStatus: {
    type: String,
    enum: ['Active', 'Disabled'],
    default: 'Active'
  },

  // --- AUTOMATIC SYNC TRACKING ---
  isSynced: {
    type: Boolean,
    default: false
  },
  lastUpdated: {
    type: Date,
    default: Date.now
  }
}, { timestamps: true });

userSchema.pre('save', async function() {
  if (!this.isModified('password')) return;
  
  // Check if it's already a bcrypt hash (starts with $2a$, $2b$, or $2y$)
  if (this.password.startsWith('$2a$') || this.password.startsWith('$2b$') || this.password.startsWith('$2y$')) {
    return;
  }

  try {
    const salt = await bcrypt.genSalt(12);
    this.password = await bcrypt.hash(this.password, salt);
  } catch (error) {
    throw error;
  }
});

module.exports = mongoose.model('User', userSchema);