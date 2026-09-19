const express = require('express');
const router = express.Router();
const LearningPath = require('../models/LearningPath');

// GET /api/learning-path - Fetch all levels sorted by level number with populated chord data
router.get('/', async (req, res) => {
  try {
    const levels = await LearningPath.find()
      .populate('chords')
      .sort({ levelNumber: 1 });
    res.status(200).json(levels);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

const adminAuth = require('../middleware/adminAuth');

// PATCH /api/learning-path/:id - Update a level (Admin use)
router.patch('/:id', adminAuth, async (req, res) => {
  try {
    const updatedLevel = await LearningPath.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updatedLevel) return res.status(404).json({ message: 'Level not found' });
    res.status(200).json(updatedLevel);
  } catch (error) {
    res.status(400).json({ message: 'Invalid level data', error: error.message });
  }
});

// DELETE /api/learning-path/:id - Delete a level (Admin use)
router.delete('/:id', adminAuth, async (req, res) => {
  try {
    const level = await LearningPath.findByIdAndDelete(req.params.id);
    if (!level) return res.status(404).json({ message: 'Level not found' });
    res.status(200).json({ message: 'Level deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// POST /api/learning-path - Create a new level (Admin use)
router.post('/', adminAuth, async (req, res) => {
  try {
    const { levelNumber, title, difficulty, chords, requiredPoints, rewardPoints } = req.body;
    const newLevel = new LearningPath({
      levelNumber,
      title,
      difficulty,
      chords,
      requiredPoints,
      rewardPoints
    });
    const savedLevel = await newLevel.save();
    res.status(201).json(savedLevel);
  } catch (error) {
    res.status(400).json({ message: 'Invalid level data', error: error.message });
  }
});

module.exports = router;