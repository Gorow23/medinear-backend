import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:geolocator/geolocator.dart';

class OwnerRegisterScreen extends StatefulWidget {
  const OwnerRegisterScreen({super.key});

  @override
  State<OwnerRegisterScreen> createState() => _OwnerRegisterScreenState();
}

class _OwnerRegisterScreenState extends State<OwnerRegisterScreen> {
  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final pharmacyController = TextEditingController();

  final locationController = TextEditingController();

  double lat = 0;

  double lng = 0;

  Future<void> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition();

    lat = position.latitude;

    lng = position.longitude;
  }

  Future<void> register() async {
    await getLocation();

    final response = await http.post(
      Uri.parse("http://localhost:8000/owner/register"),

      headers: {"Content-Type": "application/json"},

      body: jsonEncode({
        "name": nameController.text,

        "email": emailController.text,

        "password": passwordController.text,

        "pharmacy": pharmacyController.text,

        "location": locationController.text,

        "lat": lat,

        "lng": lng,
      }),
    );

    final data = jsonDecode(response.body);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(data["message"])));

    if (data["message"] == "Owner registered successfully") {
      Navigator.pop(context);
    }
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
      appBar: AppBar(title: const Text("Create Pharmacy Account")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: SingleChildScrollView(
          child: Column(
            children: [
              customField("Owner Name", nameController),

              customField("Email", emailController),

              customField("Password", passwordController),

              customField("Pharmacy Name", pharmacyController),

              customField("Location", locationController),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,

                height: 60,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),

                  onPressed: register,

                  child: const Text(
                    "Register Pharmacy",

                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
