/*
================================================================
SERVER.JS — Main Backend Server
================================================================
This is the heart of your backend.

WHAT IT DOES:
- Starts an Express web server
- Connects to MongoDB database
- Sets up all API routes
- Handles errors

HOW IT WORKS:
  Browser/Frontend → sends request to → Express Server → talks to → MongoDB
================================================================
*/

// Load environment variables from .env file
require('dotenv').config();

const express  = require('express');
const mongoose = require('mongoose');
const cors     = require('cors');

// Import route files (each handles a different part of the API)
const authRoutes     = require('./routes/auth');
const storeRoutes    = require('./routes/stores');
const productRoutes  = require('./routes/products');
const orderRoutes    = require('./routes/orders');

// Create Express app
const app = express();

// ── MIDDLEWARE ──
// Middleware = functions that run on every request before your route handlers

// CORS: Allow frontend to talk to this backend
// Without this, browser will block all requests from your Netlify site
app.use(cors({
  origin: [
    process.env.FRONTEND_URL,       // Your Netlify URL
    'http://localhost:3000',        // Local testing
    'http://127.0.0.1:5500',       // VS Code Live Server
  ],
  credentials: true
}));

// Parse JSON: Allows reading JSON data sent in request body
app.use(express.json());

// ── CONNECT TO MONGODB ──
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('✅ Connected to MongoDB Atlas'))
  .catch(err => console.error('❌ MongoDB connection error:', err));

// ── API ROUTES ──
// All routes are prefixed with /api/
// Example: GET /api/stores → returns list of stores

app.use('/api/auth',     authRoutes);      // /api/auth/register, /api/auth/login
app.use('/api/stores',   storeRoutes);     // /api/stores, /api/stores/:id
app.use('/api/products', productRoutes);   // /api/products, /api/products/:storeId
app.use('/api/orders',   orderRoutes);     // /api/orders, /api/orders/:id

// ── HEALTH CHECK ──
// Visit /api/health to check if server is running
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'MedPlus API is running',
    timestamp: new Date()
  });
});

// ── 404 HANDLER ──
// If no route matches, return 404
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// ── ERROR HANDLER ──
// Catches any errors thrown in routes
app.use((err, req, res, next) => {
  console.error('Server error:', err);
  res.status(500).json({ error: 'Something went wrong on the server' });
});

// ── START SERVER ──
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📡 API available at http://localhost:${PORT}/api`);
});
