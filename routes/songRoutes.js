const express = require('express');
const router = express.Router();
const Song = require('../models/Song');

// GET /api/songs - Get all published/active songs
router.get('/', async (req, res) => {
  try {
    const songs = await Song.find({
      status: { $in: ['published', 'Active'] }
    }).sort({ createdAt: -1 });
    res.status(200).json(songs);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// GET /api/songs/search?q=keyword - Search songs by title or artist
router.get('/search', async (req, res) => {
  try {
    const { q } = req.query;
    if (!q) {
      const songs = await Song.find({ status: { $in: ['published', 'Active'] } });
      return res.status(200).json(songs);
    }

    const regex = new RegExp(q, 'i');
    const songs = await Song.find({
      status: { $in: ['published', 'Active'] },
      $or: [{ title: regex }, { artist: regex }]
    });

    res.status(200).json(songs);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// GET /api/songs/:id - Get single song details by ID
router.get('/:id', async (req, res) => {
  try {
    const song = await Song.findById(req.params.id);
    if (!song) return res.status(404).json({ message: 'Song not found' });
    res.status(200).json(song);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// POST /api/songs - Create a new song (Admin)
router.post('/', async (req, res) => {
  try {
    const { title, artist, level, difficulty, chords, status, progression, description } = req.body;
    const newSong = new Song({
      title,
      artist,
      level: level || difficulty,
      difficulty: difficulty || level,
      chords,
      status: status || 'published',
      progression,
      description
    });
    const savedSong = await newSong.save();
    res.status(201).json(savedSong);
  } catch (error) {
    res.status(400).json({ message: 'Invalid song data', error: error.message });
  }
});

// DELETE /api/songs/:id - Delete a song (Admin)
router.delete('/:id', async (req, res) => {
  try {
    const song = await Song.findByIdAndDelete(req.params.id);
    if (!song) return res.status(404).json({ message: 'Song not found' });
    res.status(200).json({ message: 'Song deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;