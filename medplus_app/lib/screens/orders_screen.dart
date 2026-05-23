import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List orders = [];

  @override
  void initState() {
    super.initState();

    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final response = await http.get(Uri.parse("http://localhost:8000/orders"));

    final data = jsonDecode(response.body);

    setState(() {
      orders = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1115),

        elevation: 0,

        title: const Text(
          "My Orders",

          style: TextStyle(
            fontSize: 28,

            fontWeight: FontWeight.bold,

            color: Colors.white,
          ),
        ),
      ),

      body: orders.isEmpty
          ? const Center(
              child: Text(
                "No Orders Yet",

                style: TextStyle(color: Colors.white70, fontSize: 20),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),

              itemCount: orders.length,

              itemBuilder: (context, index) {
                final order = orders[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 25),

                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1D24),

                    borderRadius: BorderRadius.circular(30),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),

                        blurRadius: 20,

                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(20),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        // TOP
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            const Text(
                              "Order Delivered",

                              style: TextStyle(
                                color: Colors.white,

                                fontSize: 22,

                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,

                                vertical: 8,
                              ),

                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.15),

                                borderRadius: BorderRadius.circular(20),
                              ),

                              child: const Text(
                                "Delivered",

                                style: TextStyle(
                                  color: Colors.green,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // MEDICINES
                        ...List.generate(order["items"].length, (i) {
                          final item = order["items"][i];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),

                            padding: const EdgeInsets.all(12),

                            decoration: BoxDecoration(
                              color: const Color(0xFF232731),

                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),

                                  child: Image.network(
                                    item["image"] ??
                                        "https://images.unsplash.com/photo-1587854692152-cbe660dbde88",

                                    height: 70,

                                    width: 70,

                                    fit: BoxFit.cover,
                                  ),
                                ),

                                const SizedBox(width: 15),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        item["name"],

                                        style: const TextStyle(
                                          color: Colors.white,

                                          fontSize: 18,

                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      Text(
                                        item["pharmacy"] ?? "Apollo Pharmacy",

                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,

                                            color: Colors.red,

                                            size: 16,
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
                                    ],
                                  ),
                                ),

                                Text(
                                  "₹${item["price"]}",

                                  style: const TextStyle(
                                    color: Colors.white,

                                    fontSize: 20,

                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 10),

                        // ETA
                        Container(
                          padding: const EdgeInsets.all(16),

                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),

                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Row(
                            children: [
                              const Icon(
                                Icons.delivery_dining,

                                color: Colors.green,

                                size: 28,
                              ),

                              const SizedBox(width: 12),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  const Text(
                                    "Delivery ETA",

                                    style: TextStyle(color: Colors.white70),
                                  ),

                                  const SizedBox(height: 4),

                                  const Text(
                                    "15 - 20 mins",

                                    style: TextStyle(
                                      color: Colors.green,

                                      fontSize: 18,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // TOTAL
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            const Text(
                              "Total Amount",

                              style: TextStyle(
                                color: Colors.white70,

                                fontSize: 18,
                              ),
                            ),

                            Text(
                              "₹${order["total"]}",

                              style: const TextStyle(
                                color: Colors.white,

                                fontSize: 28,

                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // BUTTONS
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,

                                  foregroundColor: Colors.black,

                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),

                                onPressed: () {},

                                child: const Text(
                                  "Track Order",

                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),

                            const SizedBox(width: 15),

                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2A2F3A),

                                  foregroundColor: Colors.white,

                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),

                                onPressed: () {},

                                child: const Text(
                                  "Reorder",

                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
