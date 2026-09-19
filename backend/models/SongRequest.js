const mongoose = require('mongoose');

const songRequestSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  songTitle: { type: String, required: true },
  artist: { type: String, required: true },
  trackType: { type: String, default: 'Acoustic' },
  status: { type: String, default: 'In Progress' },
  completedDate: { type: Date },
  isSynced: { type: Boolean, default: false }
}, { timestamps: true });

module.exports = mongoose.model('SongRequest', songRequestSchema);
