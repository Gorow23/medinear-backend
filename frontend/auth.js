/*
================================================================
routes/auth.js — Authentication Routes
================================================================
Handles: Register & Login for both customers and store owners

ENDPOINTS:
  POST /api/auth/register  → Create new account
  POST /api/auth/login     → Login and get token
  GET  /api/auth/me        → Get current user info
================================================================
*/

const express   = require('express');
const bcrypt    = require('bcryptjs');
const jwt       = require('jsonwebtoken');
const mongoose  = require('mongoose');
const router    = express.Router();

// ── USER MODEL ──
// Defines the shape of user data in MongoDB
const userSchema = new mongoose.Schema({
  name:      { type: String, required: true },
  email:     { type: String, required: true, unique: true, lowercase: true },
  password:  { type: String, required: true },
  phone:     { type: String },

  // Role: 'customer' = buyer, 'store_owner' = pharmacy owner
  role:      { type: String, enum: ['customer', 'store_owner'], default: 'customer' },

  // If store_owner, this links to their store
  storeId:   { type: mongoose.Schema.Types.ObjectId, ref: 'Store' },

  // Customer address for delivery
  address: {
    street: String,
    city:   String,
    state:  String,
    pincode: String
  },

  createdAt: { type: Date, default: Date.now }
});

const User = mongoose.model('User', userSchema);

// ── HELPER: Generate JWT Token ──
// JWT = a secure token the frontend saves and sends with every request
// It proves the user is logged in without checking password every time
function generateToken(userId) {
  return jwt.sign(
    { userId },                     // Data stored inside token
    process.env.JWT_SECRET,         // Secret key to sign token
    { expiresIn: '7d' }             // Token expires in 7 days
  );
}

// ── MIDDLEWARE: Verify Token ──
// Used to protect routes that need login
// Add this to any route: router.get('/protected', verifyToken, handler)
function verifyToken(req, res, next) {
  // Get token from Authorization header: "Bearer <token>"
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access denied. Please login.' });
  }

  try {
    // Verify and decode the token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = decoded.userId;  // Add userId to request for use in routes
    next();                        // Continue to the route handler
  } catch (err) {
    res.status(401).json({ error: 'Invalid or expired token. Please login again.' });
  }
}

// Export so other files can use it
module.exports.verifyToken = verifyToken;


// ════════════════════════════════════════
// POST /api/auth/register
// Creates a new user account
// Body: { name, email, password, phone, role }
// ════════════════════════════════════════
router.post('/register', async (req, res) => {
  try {
    const { name, email, password, phone, role } = req.body;

    // Validate required fields
    if (!name || !email || !password) {
      return res.status(400).json({ error: 'Name, email and password are required' });
    }

    // Check if email already registered
    const existing = await User.findOne({ email });
    if (existing) {
      return res.status(400).json({ error: 'Email already registered. Please login.' });
    }

    // Hash password (never store plain text passwords)
    // bcrypt adds "salt" and hashes — even if database is stolen, passwords are safe
    const hashedPassword = await bcrypt.hash(password, 12);

    // Create new user in database
    const user = await User.create({
      name,
      email,
      password: hashedPassword,
      phone,
      role: role || 'customer'
    });

    // Generate login token
    const token = generateToken(user._id);

    // Return user data and token (don't return password)
    res.status(201).json({
      message: 'Account created successfully!',
      token,
      user: {
        id:    user._id,
        name:  user.name,
        email: user.email,
        role:  user.role,
        phone: user.phone
      }
    });

  } catch (err) {
    console.error('Register error:', err);
    res.status(500).json({ error: 'Registration failed. Please try again.' });
  }
});


// ════════════════════════════════════════
// POST /api/auth/login
// Login with email and password
// Body: { email, password }
// ════════════════════════════════════════
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Find user by email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ error: 'No account found with this email' });
    }

    // Compare entered password with hashed password in database
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ error: 'Incorrect password' });
    }

    // Generate token
    const token = generateToken(user._id);

    res.json({
      message: 'Login successful!',
      token,
      user: {
        id:      user._id,
        name:    user.name,
        email:   user.email,
        role:    user.role,
        storeId: user.storeId
      }
    });

  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ error: 'Login failed. Please try again.' });
  }
});


// ════════════════════════════════════════
// GET /api/auth/me
// Get current logged-in user's data
// Requires: Authorization header with token
// ════════════════════════════════════════
router.get('/me', verifyToken, async (req, res) => {
  try {
    // Find user by ID (from decoded token), exclude password
    const user = await User.findById(req.userId).select('-password');
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json({ user });
  } catch (err) {
    res.status(500).json({ error: 'Failed to get user data' });
  }
});

module.exports = router;
