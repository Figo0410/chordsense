// models/User.js
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: { type: String, default: 'user' },
  
  // Dashboard fields
  currentLevel: { type: Number, default: 1 },
  totalPoints: { type: Number, default: 0 },
  progressPercent: { type: Number, default: 0.0 },
  nextLevelPoints: { type: Number, default: 1000 },
  currentChord: { type: String, default: 'C Major' },

  // ADD THESE NEW STAT FIELDS:
  accuracy: { type: Number, default: 0 },         // e.g., 87 for 87%
  streak: { type: Number, default: 0 },           // e.g., 12 days
  chordsMastered: { type: Number, default: 0 }    // e.g., 23
});

module.exports = mongoose.model('User', userSchema);