const User = require('../models/User');

const adminAuth = async (req, res, next) => {
  // Safely check headers first, then req.body if it exists
  const userId = req.headers['x-user-id'] || (req.body && req.body.userId);

  if (!userId) {
    return res.status(401).json({ message: 'Authentication required' });
  }

  try {
    const user = await User.findById(userId);
    if (!user || user.role !== 'admin') {
      return res.status(403).json({ message: 'Access denied: Admin role required' });
    }
    next();
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

module.exports = adminAuth;
