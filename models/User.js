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
  }, // 👈 ADD THIS FIELD!
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
  
  // Fields needed for Password Reset:
  resetPasswordToken: String,
  resetPasswordExpires: Date,
});

module.exports = mongoose.model('User', userSchema);