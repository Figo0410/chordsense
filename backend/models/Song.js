const mongoose = require('mongoose');

const chordProgressionSchema = new mongoose.Schema({
  order: { type: Number, required: true },
  chord: { type: String, required: true, trim: true }
}, { _id: false });

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
  difficulty: {
    type: String,
    enum: ['Beginner', 'Intermediate', 'Advanced'],
    default: 'Beginner',
  },
  // Legacy support for existing records
  level: {
    type: String,
    enum: ['Beginner', 'Intermediate', 'Advanced'],
    default: 'Beginner',
  },
  description: {
    type: String,
    default: 'A beginner-friendly song for practicing chord transitions.',
  },
  chords: {
    type: mongoose.Schema.Types.Mixed,
    required: true,
  },
  chordList: [{
    type: String,
    trim: true
  }],
  progression: [chordProgressionSchema],
  audioUrl: {
    type: String,
    default: ''
  },
  coverImage: {
    type: String,
    default: ''
  },
  coverImageUrl: {
    type: String,
    default: ''
  },
  durationMinutes: {
    type: Number,
    default: 3
  },
  status: {
    type: String,
    enum: ['Active', 'published', 'Draft', 'Archived'],
    default: 'published',
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

// Pre-save middleware to synchronize level/difficulty and array/string chords
songSchema.pre('save', function(next) {
  if (this.difficulty && !this.level) {
    this.level = this.difficulty;
  } else if (this.level && !this.difficulty) {
    this.difficulty = this.level;
  }

  if (Array.isArray(this.chords)) {
    this.chordList = this.chords;
  } else if (typeof this.chords === 'string') {
    this.chordList = this.chords.split(',').map(c => c.trim()).filter(Boolean);
  }
  next();
});

module.exports = mongoose.model('Song', songSchema);