const dns = require('dns');
dns.setDefaultResultOrder('ipv4first'); // Standardizes IP lookup
dns.setServers(['8.8.8.8', '1.1.1.1']);


// server.js
const express = require('express');
const cors = require('cors');
require('dotenv').config();

const connectDB = require('./config/db.js');

const app = express();

// 1. Connect to Database
connectDB();

// 2. Middleware
app.use(cors()); // Allows Flutter app to make cross-origin requests
app.use(express.json()); // Parses incoming JSON payloads

app.use('/api/songs', require('./routes/songRoutes'));

// 3. Test Route
app.get('/', (req, res) => {
  res.send('API is running...');
});

// 4. Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running in ${process.env.NODE_ENV || 'development'} mode on port ${PORT}`);
});