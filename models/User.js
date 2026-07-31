// models/User.js
const mongoose = require('mongoose');

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
  chordsMastered: { 
    type: Number, 
    default: 0 
  },
  
  // Array to track unlocked badge IDs for automatic point rewards
  unlockedBadges: { 
    type: [String], 
    default: [] 
  },

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
    day: String,
    date: String,
    duration: String,
    accuracy: Number,
    chordsCount: Number
  }],

  // Fields needed for Password Reset:
  resetPasswordToken: String,
  resetPasswordExpires: Date,
});

module.exports = mongoose.model('User', userSchema);