const express = require('express');
const router = express.Router();
const SongRequest = require('../models/SongRequest');
const adminAuth = require('../middleware/adminAuth');

// User: POST /api/song-requests - Create a request
router.post('/', async (req, res) => {
  try {
    const { userId, songTitle, artist } = req.body;
    const newRequest = new SongRequest({ userId, songTitle, artist, isSynced: false });
    const savedRequest = await newRequest.save();
    res.status(201).json(savedRequest);
  } catch (error) {
    res.status(400).json({ message: 'Error creating request', error: error.message });
  }
});

// User: GET /api/song-requests/user/:userId - Fetch own requests
router.get('/user/:userId', async (req, res) => {
  try {
    const requests = await SongRequest.find({ userId: req.params.userId }).sort({ createdAt: -1 });
    res.json(requests);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching requests', error: error.message });
  }
});

// Admin: GET /api/admin/song-requests - Fetch all
router.get('/admin', adminAuth, async (req, res) => {
  try {
    const requests = await SongRequest.find().populate('userId', 'username').sort({ createdAt: -1 });
    res.json(requests);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching requests', error: error.message });
  }
});

// Admin: PATCH /api/admin/song-requests/:id - Update status
router.patch('/admin/:id', adminAuth, async (req, res) => {
  try {
    const updatedRequest = await SongRequest.findByIdAndUpdate(
      req.params.id, 
      { ...req.body, isSynced: false }, 
      { new: true }
    );
    res.json(updatedRequest);
  } catch (error) {
    res.status(400).json({ message: 'Error updating request', error: error.message });
  }
});

module.exports = router;
