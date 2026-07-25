// routes/songRoutes.js
const express = require('express');
const router = express.Router();
const Song = require('../models/Song');

// GET /api/songs - Get all songs
router.get('/', async (req, res) => {
  try {
    const songs = await Song.find().sort({ createdAt: -1 });
    res.status(200).json(songs);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// POST /api/songs - Create a new song
router.post('/', async (req, res) => {
  try {
    const { title, artist, level, chords, status } = req.body;
    const newSong = new Song({ title, artist, level, chords, status });
    const savedSong = await newSong.save();
    res.status(201).json(savedSong);
  } catch (error) {
    res.status(400).json({ message: 'Invalid song data', error: error.message });
  }
});

// DELETE /api/songs/:id - Delete a song
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