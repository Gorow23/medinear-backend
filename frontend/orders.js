/*
================================================================
routes/orders.js — Order Management
================================================================
Customers place orders from a specific store.

ENDPOINTS:
  POST /api/orders              → Place new order
  GET  /api/orders/my           → Customer: get my orders
  GET  /api/orders/store        → Store owner: get their store's orders
  PUT  /api/orders/:id/status   → Store owner: update order status
================================================================
*/

const express  = require('express');
const mongoose = require('mongoose');
const router   = express.Router();
const { verifyToken } = require('./auth');

// ── ORDER MODEL ──
const orderSchema = new mongoose.Schema({

  // Who placed the order
  customerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },

  // Which store the order is from (TENANT KEY)
  storeId: { type: mongoose.Schema.Types.ObjectId, ref: 'Store', required: true },

  // Items in the order
  items: [{
    productId:   { type: mongoose.Schema.Types.ObjectId, ref: 'Product' },
    productName: { type: String },   // Store name at time of order
    price:       { type: Number },   // Store price at time of order
    quantity:    { type: Number },
    emoji:       { type: String }
  }],

  // Order totals
  subtotal:     { type: Number, required: true },
  deliveryFee:  { type: Number, default: 0 },
  totalAmount:  { type: Number, required: true },

  // Delivery address
  deliveryAddress: {
    street:  String,
    city:    String,
    pincode: String
  },

  // Order status flow:
  // pending → confirmed → preparing → out_for_delivery → delivered
  // OR: pending → cancelled
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'preparing', 'out_for_delivery', 'delivered', 'cancelled'],
    default: 'pending'
  },

  // Optional prescription for Rx medicines
  prescriptionUrl: { type: String },

  // Notes
  customerNote: { type: String },
  storeNote:    { type: String },

  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

const Order = mongoose.model('Order', orderSchema);


// ════════════════════════════════════════
// POST /api/orders
// Customer places a new order
// Body: { storeId, items, deliveryAddress, customerNote }
// ════════════════════════════════════════
router.post('/', verifyToken, async (req, res) => {
  try {
    const { storeId, items, deliveryAddress, customerNote } = req.body;

    if (!storeId || !items || items.length === 0) {
      return res.status(400).json({ error: 'Store and items are required' });
    }

    // Calculate totals
    const subtotal = items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    const deliveryFee = subtotal > 500 ? 0 : 40;  // Free delivery over ₹500
    const totalAmount = subtotal + deliveryFee;

    // Create the order
    const order = await Order.create({
      customerId: req.userId,
      storeId,
      items,
      subtotal,
      deliveryFee,
      totalAmount,
      deliveryAddress,
      customerNote
    });

    // Update store's total order count
    const Store = mongoose.model('Store');
    await Store.findByIdAndUpdate(storeId, { $inc: { totalOrders: 1 } });

    res.status(201).json({
      message: 'Order placed successfully!',
      order,
      summary: {
        subtotal:    `₹${subtotal}`,
        deliveryFee: deliveryFee === 0 ? 'FREE' : `₹${deliveryFee}`,
        total:       `₹${totalAmount}`
      }
    });

  } catch (err) {
    console.error('Place order error:', err);
    res.status(500).json({ error: 'Failed to place order' });
  }
});


// ════════════════════════════════════════
// GET /api/orders/my
// Customer: get their own orders
// ════════════════════════════════════════
router.get('/my', verifyToken, async (req, res) => {
  try {
    const orders = await Order.find({ customerId: req.userId })
      .populate('storeId', 'name address phone')   // Include store name
      .sort({ createdAt: -1 });                     // Newest first

    res.json({ count: orders.length, orders });

  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch your orders' });
  }
});


// ════════════════════════════════════════
// GET /api/orders/store
// Store owner: get all orders for their store
// ════════════════════════════════════════
router.get('/store', verifyToken, async (req, res) => {
  try {
    // Find the store owned by this user
    const Store = mongoose.model('Store');
    const store = await Store.findOne({ ownerId: req.userId });

    if (!store) {
      return res.status(403).json({ error: 'No store found for this account' });
    }

    const { status } = req.query;
    let filter = { storeId: store._id };
    if (status) filter.status = status;

    const orders = await Order.find(filter)
      .populate('customerId', 'name phone email')
      .sort({ createdAt: -1 });

    res.json({ count: orders.length, orders });

  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch store orders' });
  }
});


// ════════════════════════════════════════
// PUT /api/orders/:id/status
// Store owner updates order status
// Body: { status, storeNote }
// ════════════════════════════════════════
router.put('/:id/status', verifyToken, async (req, res) => {
  try {
    const { status, storeNote } = req.body;
    const validStatuses = ['confirmed', 'preparing', 'out_for_delivery', 'delivered', 'cancelled'];

    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ error: 'Order not found' });

    // Verify store ownership
    const Store = mongoose.model('Store');
    const store = await Store.findOne({ ownerId: req.userId });

    if (!store || store._id.toString() !== order.storeId.toString()) {
      return res.status(403).json({ error: 'Not authorized to update this order' });
    }

    const updated = await Order.findByIdAndUpdate(
      req.params.id,
      { status, storeNote, updatedAt: Date.now() },
      { new: true }
    );

    res.json({ message: `Order status updated to: ${status}`, order: updated });

  } catch (err) {
    res.status(500).json({ error: 'Failed to update order status' });
  }
});

module.exports = router;
