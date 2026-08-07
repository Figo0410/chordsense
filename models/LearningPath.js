const mongoose = require('mongoose');

const LearningPathSchema = new mongoose.Schema({
  levelNumber: { type: Number, required: true, unique: true },
  title: { type: String, required: true },
  description: { type: String, default: '' },
  difficulty: { type: String, required: true }, // "Beginner", "Intermediate", etc.
  chords: [{ type: String }],
  
  // Recommended or unlockable songs for this level
  associatedSongs: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Song'
  }],

  requiredPoints: { type: Number, default: 0 },
  rewardPoints: { type: Number, default: 100 },
  
  // Threshold accuracy needed to consider the level passed (e.g., 80%)
  passingAccuracy: { type: Number, default: 75 },
  
  status: { type: String, enum: ['Active', 'Draft', 'Archived'], default: 'Active' }
}, { timestamps: true });

// Added 'learning_paths' as the 3rd argument to map directly to your MongoDB collection name
module.exports = mongoose.model('LearningPath', LearningPathSchema, 'learning_paths');