import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final nameController = TextEditingController();

  final priceController = TextEditingController();

  final pharmacyController = TextEditingController();

  final locationController = TextEditingController();

  final imageController = TextEditingController();

  Future<void> addMedicine() async {
    final response = await http.post(
      Uri.parse("http://127.0.0.1:8000/admin/add-medicine"),

      headers: {"Content-Type": "application/json"},

      body: jsonEncode({
        "name": nameController.text,

        "price": int.parse(priceController.text),

        "pharmacy": pharmacyController.text,

        "location": locationController.text,

        "image": imageController.text,
      }),
    );

    final data = jsonDecode(response.body);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(data["message"])));

    nameController.clear();

    priceController.clear();

    pharmacyController.clear();

    locationController.clear();

    imageController.clear();
  }

  Widget customField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),

      child: TextField(
        controller: controller,

        decoration: InputDecoration(
          hintText: hint,

          filled: true,

          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),

            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(title: const Text("Admin Dashboard")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            customField("Medicine Name", nameController),

            customField("Price", priceController),

            customField("Pharmacy", pharmacyController),

            customField("Location", locationController),

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
