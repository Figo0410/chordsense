const mongoose = require('mongoose');

const LearningPathSchema = new mongoose.Schema({
  levelNumber: { type: Number, required: true, unique: true },
  title: { type: String, required: true },
  difficulty: { type: String, required: true }, // "Beginner", "Intermediate", etc.
  chords: [{ type: String }],
  requiredPoints: { type: Number, default: 0 },
  rewardPoints: { type: Number, default: 100 },
  status: { type: String, default: 'Active' }
});

// Added 'learning_paths' as the 3rd argument to map directly to your MongoDB collection name
module.exports = mongoose.model('LearningPath', LearningPathSchema, 'learning_paths');