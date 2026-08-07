const mongoose = require('mongoose');

const songSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true,
  },
  artist: {
    type: String,
    required: true,
    trim: true,
  },
  level: {
    type: String,
    enum: ['Beginner', 'Intermediate', 'Advanced'],
    default: 'Beginner',
  },
  chords: {
    type: String,
    required: true,
  },
  // Array of parsed chord names for easy querying & filtering by chord
  chordList: [{
    type: String,
    trim: true
  }],
  // Audio file URL or asset path for playback
  audioUrl: {
    type: String,
    default: ''
  },
  // Cover art image path or URL
  coverImageUrl: {
    type: String,
    default: ''
  },
  tempo: {
    type: Number, // BPM
    default: 120
  },
  duration: {
    type: Number, // Seconds
    default: 0
  },
  difficultyScore: {
    type: Number,
    default: 1
  },
  status: {
    type: String,
    enum: ['Active', 'Draft', 'Archived'],
    default: 'Active',
  },
}, { timestamps: true });

module.exports = mongoose.model('Song', songSchema);