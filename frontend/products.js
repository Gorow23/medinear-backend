/*
================================================================
routes/products.js — Product Management (Per Store)
================================================================
Each store manages their own products.
MULTI-TENANCY: Products always belong to a specific storeId.

ENDPOINTS:
  GET  /api/products?storeId=xxx     → Get all products for a store
  GET  /api/products/:id             → Get one product
  POST /api/products                 → Add product (store owner only)
  PUT  /api/products/:id             → Update product
  DELETE /api/products/:id           → Delete product
================================================================
*/

const express  = require('express');
const mongoose = require('mongoose');
const router   = express.Router();
const { verifyToken } = require('./auth');

// ── PRODUCT MODEL ──
const productSchema = new mongoose.Schema({

  // TENANT KEY: Every product belongs to exactly one store
  storeId: { type: mongoose.Schema.Types.ObjectId, ref: 'Store', required: true, index: true },

  // Product details
  name:        { type: String, required: true },
  description: { type: String },
  category:    {
    type: String,
    enum: ['medicine', 'vitamin', 'device', 'first_aid', 'skincare', 'baby', 'dental', 'other'],
    required: true
  },
  emoji:       { type: String, default: '💊' },   // Emoji for display
  image:       { type: String },                   // URL to product image

  // Pricing
  price:    { type: Number, required: true },
  oldPrice: { type: Number },                      // For showing discounts

  // Stock
  stock:       { type: Number, default: 0 },
  inStock:     { type: Boolean, default: true },

  // Medicine specific
  requiresPrescription: { type: Boolean, default: false },
  manufacturer:         { type: String },
  expiryDate:           { type: Date },

  // Visibility
  isActive: { type: Boolean, default: true },

  createdAt: { type: Date, default: Date.now }
});

const Product = mongoose.model('Product', productSchema);


// ════════════════════════════════════════
// GET /api/products?storeId=xxx
// Get all products for a specific store
// This is how multi-tenancy works — always filter by storeId
// ════════════════════════════════════════
router.get('/', async (req, res) => {
  try {
    const { storeId, category, search, inStock } = req.query;

    if (!storeId) {
      return res.status(400).json({ error: 'storeId is required' });
    }

    // Always filter by storeId — this isolates each store's data
    let filter = { storeId, isActive: true };

    if (category) filter.category = category;
    if (inStock === 'true') filter.inStock = true;
    if (search) filter.name = new RegExp(search, 'i');

    const products = await Product.find(filter).sort({ name: 1 });

    res.json({ count: products.length, products });

  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch products' });
  }
});


// ════════════════════════════════════════
// GET /api/products/:id
// Get single product details
// ════════════════════════════════════════
router.get('/:id', async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);

    if (!product || !product.isActive) {
      return res.status(404).json({ error: 'Product not found' });
    }

    res.json({ product });

  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch product' });
  }
});


// ════════════════════════════════════════
// POST /api/products
// Add a new product to store
// Store owner only
// ════════════════════════════════════════
router.post('/', verifyToken, async (req, res) => {
  try {
    const {
      name, description, category, emoji, price,
      oldPrice, stock, requiresPrescription, manufacturer
    } = req.body;

    // Get the store owned by this user
    const Store = mongoose.model('Store');
    const store = await Store.findOne({ ownerId: req.userId });

    if (!store) {
      return res.status(403).json({ error: 'You do not own a store. Register a store first.' });
    }

    // Create product linked to this store
    const product = await Product.create({
      storeId: store._id,       // TENANT KEY: links product to store
      name,
      description,
      category,
      emoji: emoji || '💊',
      price,
      oldPrice,
      stock: stock || 0,
      inStock: (stock || 0) > 0,
      requiresPrescription: requiresPrescription || false,
      manufacturer
    });

    res.status(201).json({
      message: 'Product added successfully!',
      product
    });

  } catch (err) {
    console.error('Add product error:', err);
    res.status(500).json({ error: 'Failed to add product' });
  }
});


// ════════════════════════════════════════
// PUT /api/products/:id
// Update a product
// Store owner only — can only update their own products
// ════════════════════════════════════════
router.put('/:id', verifyToken, async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);

    if (!product) return res.status(404).json({ error: 'Product not found' });

    // Verify the store belongs to this user
    const Store = mongoose.model('Store');
    const store = await Store.findOne({ ownerId: req.userId });

    if (!store || store._id.toString() !== product.storeId.toString()) {
      return res.status(403).json({ error: 'Not authorized to edit this product' });
    }

    const allowed = ['name', 'description', 'category', 'emoji', 'price', 'oldPrice', 'stock', 'inStock', 'requiresPrescription', 'isActive'];
    const updates = {};
    allowed.forEach(field => {
      if (req.body[field] !== undefined) updates[field] = req.body[field];
    });

    // Auto-update inStock based on stock quantity
    if (updates.stock !== undefined) {
      updates.inStock = updates.stock > 0;
    }

    const updated = await Product.findByIdAndUpdate(req.params.id, updates, { new: true });

    res.json({ message: 'Product updated!', product: updated });

  } catch (err) {
    res.status(500).json({ error: 'Failed to update product' });
  }
});


// ════════════════════════════════════════
// DELETE /api/products/:id
// Soft delete (sets isActive = false)
// ════════════════════════════════════════
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) return res.status(404).json({ error: 'Product not found' });

    const Store = mongoose.model('Store');
    const store = await Store.findOne({ ownerId: req.userId });

    if (!store || store._id.toString() !== product.storeId.toString()) {
      return res.status(403).json({ error: 'Not authorized' });
    }

    // Soft delete — keeps data but hides it
    await Product.findByIdAndUpdate(req.params.id, { isActive: false });

    res.json({ message: 'Product removed' });

  } catch (err) {
    res.status(500).json({ error: 'Failed to delete product' });
  }
});

module.exports = router;
