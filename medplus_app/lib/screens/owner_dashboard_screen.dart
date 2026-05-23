import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class OwnerDashboardScreen extends StatefulWidget {
  final Map owner;

  const OwnerDashboardScreen({super.key, required this.owner});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final nameController = TextEditingController();

  final priceController = TextEditingController();

  final imageController = TextEditingController();

  Future<void> addMedicine() async {
    final response = await http.post(
      Uri.parse("http://127.0.0.1:8000/owner/add-medicine"),

      headers: {"Content-Type": "application/json"},

      body: jsonEncode({
        "name": nameController.text,

        "price": int.parse(priceController.text),

        "pharmacy": widget.owner["pharmacy"],

        "location": widget.owner["location"],

        "image": imageController.text,
      }),
    );

    final data = jsonDecode(response.body);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(data["message"])));

    nameController.clear();

    priceController.clear();

    imageController.clear();
  }

  Widget customField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),

      child: TextField(
        controller: controller,

        decoration: InputDecoration(
          hintText: hint,

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.owner["pharmacy"])),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            customField("Medicine Name", nameController),

            customField("Price", priceController),

            customField("Image URL", imageController),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              height: 60,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),

                onPressed: addMedicine,

                child: const Text(
                  "Add Medicine",

                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
