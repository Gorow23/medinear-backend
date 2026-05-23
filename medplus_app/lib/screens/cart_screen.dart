import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CartScreen extends StatefulWidget {
  final List cart;

  const CartScreen({super.key, required this.cart});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double getTotal() {
    double total = 0;

    for (var item in widget.cart) {
      total += item["price"];
    }

    return total;
  }

  void removeItem(int index) {
    setState(() {
      widget.cart.removeAt(index);
    });
  }

  Future<void> placeOrder() async {
    final orderData = {"items": widget.cart, "total": getTotal()};

    final response = await http.post(
      Uri.parse("http://localhost:8000/orders/create"),

      headers: {"Content-Type": "application/json"},

      body: jsonEncode(orderData),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,

          content: Text("Order Placed Successfully 🚀"),
        ),
      );

      setState(() {
        widget.cart.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1115),

        elevation: 0,

        title: const Text(
          "My Cart",

          style: TextStyle(
            color: Colors.white,

            fontSize: 28,

            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: widget.cart.isEmpty
          ? const Center(
              child: Text(
                "Cart is empty",

                style: TextStyle(color: Colors.white70, fontSize: 22),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),

                    itemCount: widget.cart.length,

                    itemBuilder: (context, index) {
                      final item = widget.cart[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),

                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1D24),

                          borderRadius: BorderRadius.circular(28),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),

                              blurRadius: 20,

                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),

                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),

                              child: Image.network(
                                item["image"] ??
                                    "https://images.unsplash.com/photo-1587854692152-cbe660dbde88",

                                height: 100,

                                width: 100,

                                fit: BoxFit.cover,
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    item["name"],

                                    style: const TextStyle(
                                      color: Colors.white,

                                      fontSize: 22,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    item["pharmacy"] ?? "Apollo Pharmacy",

                                    style: TextStyle(
                                      color: Colors.grey.shade400,

                                      fontSize: 15,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,

                                        color: Colors.red,

                                        size: 18,
                                      ),

                                      const SizedBox(width: 4),

                                      Text(
                                        item["location"] ?? "Pune",

                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,

                                      vertical: 6,
                                    ),

                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.15),

                                      borderRadius: BorderRadius.circular(20),
                                    ),

                                    child: const Text(
                                      "Fast Delivery",

                                      style: TextStyle(
                                        color: Colors.green,

                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,

                              children: [
                                Text(
                                  "₹${item["price"]}",

                                  style: const TextStyle(
                                    color: Colors.white,

                                    fontSize: 24,

                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                GestureDetector(
                                  onTap: () {
                                    removeItem(index);
                                  },

                                  child: Container(
                                    padding: const EdgeInsets.all(10),

                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.15),

                                      borderRadius: BorderRadius.circular(14),
                                    ),

                                    child: const Icon(
                                      Icons.delete,

                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // BOTTOM CHECKOUT
                Container(
                  padding: const EdgeInsets.all(25),

                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1D24),

                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(35),
                    ),
                  ),

                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          const Text(
                            "Subtotal",

                            style: TextStyle(
                              color: Colors.white70,

                              fontSize: 18,
                            ),
                          ),

                          Text(
                            "₹${getTotal()}",

                            style: const TextStyle(
                              color: Colors.white,

                              fontSize: 22,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          const Text(
                            "Delivery Fee",

                            style: TextStyle(
                              color: Colors.white70,

                              fontSize: 18,
                            ),
                          ),

                          const Text(
                            "FREE",

                            style: TextStyle(
                              color: Colors.green,

                              fontSize: 18,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Divider(color: Colors.grey.shade800),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          const Text(
                            "Total",

                            style: TextStyle(
                              color: Colors.white,

                              fontSize: 22,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            "₹${getTotal()}",

                            style: const TextStyle(
                              color: Colors.green,

                              fontSize: 30,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,

                        height: 65,

                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),

                          onPressed: placeOrder,

                          child: const Text(
                            "Proceed To Checkout",

                            style: TextStyle(
                              color: Colors.white,

                              fontSize: 20,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
