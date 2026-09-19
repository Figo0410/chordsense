const mongoose = require('mongoose');
const User = require('../models/User');
const Song = require('../models/Song');
const LearningPath = require('../models/LearningPath');
const SongRequest = require('../models/SongRequest');

exports.syncToCloud = async (req, res) => {
  if (!process.env.ATLAS_URI) {
    return res.status(400).json({ message: 'ATLAS_URI is not defined in .env' });
  }

  let cloudConn = null;
  try {
    cloudConn = await mongoose.createConnection(process.env.ATLAS_URI).asPromise();
    
    const CloudUser = cloudConn.model('User', User.schema, 'users');
    const CloudSong = cloudConn.model('Song', Song.schema);
    const CloudLearningPath = cloudConn.model('LearningPath', LearningPath.schema, 'learning_paths');
    const CloudSongRequest = cloudConn.model('SongRequest', SongRequest.schema, 'songrequests');

    // 1. Sync Users
    const unsyncedUsers = await User.find({ isSynced: false });
    for (let u of unsyncedUsers) {
      const data = u.toObject();
      data.isSynced = true;
      await CloudUser.findByIdAndUpdate(u._id, data, { upsert: true, returnDocument: 'after' });
      u.isSynced = true;
      await u.save();
    }

    // 2. Sync Songs
    const unsyncedSongs = await Song.find({ isSynced: false });
    for (let s of unsyncedSongs) {
      const data = s.toObject();
      data.isSynced = true;
      await CloudSong.findByIdAndUpdate(s._id, data, { upsert: true, returnDocument: 'after' });
      s.isSynced = true;
      await s.save();
    }

    // 3. Sync Learning Paths
    const unsyncedPaths = await LearningPath.find({ isSynced: false });
    for (let lp of unsyncedPaths) {
      const data = lp.toObject();
      data.isSynced = true;
      await CloudLearningPath.findByIdAndUpdate(lp._id, data, { upsert: true, returnDocument: 'after' });
      lp.isSynced = true;
      await lp.save();
    }

    // 4. Sync Song Requests
    const unsyncedRequests = await SongRequest.find({ isSynced: false });
    for (let sr of unsyncedRequests) {
      const data = sr.toObject();
      data.isSynced = true;
      await CloudSongRequest.findByIdAndUpdate(sr._id, data, { upsert: true, returnDocument: 'after' });
      sr.isSynced = true;
      await sr.save();
    }

    await cloudConn.close();
    res.status(200).json({ 
      success: true, 
      message: 'Local database successfully synchronized with Atlas Cloud.',
      syncedCounts: {
        users: unsyncedUsers.length,
        songs: unsyncedSongs.length,
        learningPaths: unsyncedPaths.length,
        songRequests: unsyncedRequests.length
      }
    });

  } catch (error) {
    if (cloudConn) await cloudConn.close();
    res.status(500).json({ 
      success: false, 
      message: 'Sync failed. Ensure Wi-Fi is connected and ATLAS_URI is correct.', 
      error: error.message 
    });
  }
};