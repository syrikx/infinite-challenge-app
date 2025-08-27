const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// MongoDB connection
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => {
  console.log('✅ MongoDB connected successfully');
})
.catch((error) => {
  console.error('❌ MongoDB connection error:', error);
  process.exit(1);
});

// Import routes
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const magazineRoutes = require('./routes/magazines');
const communityRoutes = require('./routes/community');

// Routes with base path support
const basePath = process.env.BASE_PATH || '';
app.use(`${basePath}/api/auth`, authRoutes);
app.use(`${basePath}/api/users`, userRoutes);
app.use(`${basePath}/api/magazines`, magazineRoutes);
app.use(`${basePath}/api/community`, communityRoutes);

// Health check endpoint
app.get(`${basePath}/health`, (req, res) => {
  res.status(200).json({
    status: 'OK',
    message: 'DiggingYuhak API Server is running',
    timestamp: new Date().toISOString(),
    mongodb: mongoose.connection.readyState === 1 ? 'Connected' : 'Disconnected'
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Endpoint not found',
    message: `Cannot ${req.method} ${req.originalUrl}`
  });
});

// Error handling middleware
app.use((error, req, res, next) => {
  console.error('Error:', error);
  res.status(error.status || 500).json({
    error: error.message || 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { stack: error.stack })
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 DiggingYuhak API Server running on port ${PORT}`);
  console.log(`📱 Environment: ${process.env.NODE_ENV}`);
  console.log(`🗄️  MongoDB URI: ${process.env.MONGODB_URI}`);
});

module.exports = app;