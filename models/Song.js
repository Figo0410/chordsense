// models/Song.js
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
  status: {
    type: String,
    enum: ['Active', 'Draft', 'Archived'],
    default: 'Active',
  },
}, { timestamps: true });

module.exports = mongoose.model('Song', songSchema);