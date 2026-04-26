/*
================================================================
routes/stores.js — Store (Tenant) Management
================================================================
This is the CORE of multi-tenancy.
Each pharmacy = one "Store" (tenant) in the database.

ENDPOINTS:
  GET  /api/stores              → Get all stores (with location filter)
  GET  /api/stores/:id          → Get one store's details
  POST /api/stores              → Register a new pharmacy (store owner)
  PUT  /api/stores/:id          → Update store info
  GET  /api/stores/nearby       → Get stores near a location
================================================================
*/

const express  = require('express');
const mongoose = require('mongoose');
const router   = express.Router();
const { verifyToken } = require('./auth');

// ── STORE MODEL ──
// Each document = one pharmacy on the platform
const storeSchema = new mongoose.Schema({

  // Basic store info
  name:        { type: String, required: true },
  description: { type: String },
  phone:       { type: String, required: true },
  email:       { type: String },
  logo:        { type: String },           // URL to logo image

  // Physical address
  address: {
    street:  { type: String, required: true },
    city:    { type: String, required: true },
    state:   { type: String, required: true },
    pincode: { type: String, required: true },
  },

  // GPS coordinates for "nearby" search
  // MongoDB supports geospatial queries with this format
  location: {
    type:        { type: String, default: 'Point' },
    coordinates: { type: [Number], default: [0, 0] }
    // coordinates = [longitude, latitude]
    // Example Mumbai: [72.8777, 19.0760]
  },

  // Opening hours
  hours: {
    weekdays: { type: String, default: 'Mon–Sat: 9 AM – 9 PM' },
    sunday:   { type: String, default: 'Sun: 10 AM – 6 PM' }
  },

  // Who owns this store (links to User with role='store_owner')
  ownerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },

  // Store status
  isActive:   { type: Boolean, default: true },
  isVerified: { type: Boolean, default: false }, // Admin verifies stores

  // Stats (updated when orders come in)
  totalOrders:   { type: Number, default: 0 },
  averageRating: { type: Number, default: 0 },
  totalReviews:  { type: Number, default: 0 },

  createdAt: { type: Date, default: Date.now }
});

// Create geospatial index — enables fast "find nearby" queries
storeSchema.index({ location: '2dsphere' });

const Store = mongoose.model('Store', storeSchema);


// ════════════════════════════════════════
// GET /api/stores
// Get all active stores
// Optional query: ?city=Mumbai&pincode=400050
// ════════════════════════════════════════
router.get('/', async (req, res) => {
  try {
    const { city, pincode, search } = req.query;

    // Build filter object dynamically
    let filter = { isActive: true };

    if (city)    filter['address.city']    = new RegExp(city, 'i');    // case-insensitive
    if (pincode) filter['address.pincode'] = pincode;
    if (search)  filter.name               = new RegExp(search, 'i');

    const stores = await Store.find(filter)
      .select('-ownerId')     // Don't expose owner ID to public
      .sort({ averageRating: -1 }); // Sort by rating

    res.json({ count: stores.length, stores });

  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch stores' });
  }
});


// ════════════════════════════════════════
// GET /api/stores/nearby
// Find stores within X km of given coordinates
// Query: ?lat=19.0760&lng=72.8777&radius=5
// ════════════════════════════════════════
router.get('/nearby', async (req, res) => {
  try {
    const { lat, lng, radius = 5 } = req.query;

    if (!lat || !lng) {
      return res.status(400).json({ error: 'lat and lng are required' });
    }

    // MongoDB geospatial query: find stores within radius km
    // $near + $maxDistance uses the 2dsphere index we created
    const stores = await Store.find({
      isActive: true,
      location: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [parseFloat(lng), parseFloat(lat)]  // [longitude, latitude]
          },
          $maxDistance: parseInt(radius) * 1000  // Convert km to meters
        }
      }
    }).select('-ownerId');

    // Add distance to each store result
    res.json({ count: stores.length, stores });

  } catch (err) {
    console.error('Nearby stores error:', err);
    res.status(500).json({ error: 'Failed to find nearby stores' });
  }
});


// ════════════════════════════════════════
// GET /api/stores/:id
// Get one store's full details
// ════════════════════════════════════════
router.get('/:id', async (req, res) => {
  try {
    const store = await Store.findById(req.params.id).select('-ownerId');

    if (!store) {
      return res.status(404).json({ error: 'Store not found' });
    }

    res.json({ store });

  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch store' });
  }
});


// ════════════════════════════════════════
// POST /api/stores
// Register a new pharmacy store
// Requires login (store_owner role)
// Body: { name, phone, address, location }
// ════════════════════════════════════════
router.post('/', verifyToken, async (req, res) => {
  try {
    const { name, description, phone, email, address, location, hours } = req.body;

    // Validate
    if (!name || !phone || !address) {
      return res.status(400).json({ error: 'Name, phone and address are required' });
    }

    // Check if this owner already has a store
    const existing = await Store.findOne({ ownerId: req.userId });
    if (existing) {
      return res.status(400).json({ error: 'You already have a registered store' });
    }

    // Create the store
    const store = await Store.create({
      name,
      description,
      phone,
      email,
      address,
      location: location || { type: 'Point', coordinates: [0, 0] },
      hours,
      ownerId: req.userId
    });

    // Link store to user
    const { User } = require('mongoose').models;
    await User.findByIdAndUpdate(req.userId, {
      role: 'store_owner',
      storeId: store._id
    });

    res.status(201).json({
      message: 'Store registered successfully!',
      store
    });

  } catch (err) {
    console.error('Create store error:', err);
    res.status(500).json({ error: 'Failed to register store' });
  }
});


// ════════════════════════════════════════
// PUT /api/stores/:id
// Update store information
// Only the store owner can update their store
// ════════════════════════════════════════
router.put('/:id', verifyToken, async (req, res) => {
  try {
    // Find store and verify ownership
    const store = await Store.findById(req.params.id);

    if (!store) {
      return res.status(404).json({ error: 'Store not found' });
    }

    // Check the logged-in user owns this store
    if (store.ownerId.toString() !== req.userId) {
      return res.status(403).json({ error: 'Not authorized to edit this store' });
    }

    // Update allowed fields
    const allowed = ['name', 'description', 'phone', 'email', 'address', 'hours', 'logo'];
    const updates = {};
    allowed.forEach(field => {
      if (req.body[field] !== undefined) updates[field] = req.body[field];
    });

    const updated = await Store.findByIdAndUpdate(
      req.params.id,
      updates,
      { new: true }  // Return updated document
    );

    res.json({ message: 'Store updated!', store: updated });

  } catch (err) {
    res.status(500).json({ error: 'Failed to update store' });
  }
});

module.exports = router;
