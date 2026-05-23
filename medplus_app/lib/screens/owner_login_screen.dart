import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'owner_dashboard_screen.dart';

import 'owner_register_screen.dart';

class OwnerLoginScreen extends StatefulWidget {
  @override
  State<OwnerLoginScreen> createState() => _OwnerLoginScreenState();
}

class _OwnerLoginScreenState extends State<OwnerLoginScreen> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  Future<void> login() async {
    final response = await http.post(
      Uri.parse("http://127.0.0.1:8000/owner/login"),

      headers: {"Content-Type": "application/json"},

      body: jsonEncode({
        "email": emailController.text,

        "password": passwordController.text,
      }),
    );

    final data = jsonDecode(response.body);

    if (data["message"] == "Login successful") {
      Navigator.push(
        context,

        MaterialPageRoute(
          builder: (_) => OwnerDashboardScreen(owner: data["owner"]),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data["message"])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Owner Login")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: emailController,

              decoration: const InputDecoration(hintText: "Email"),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,

              obscureText: true,

              decoration: const InputDecoration(hintText: "Password"),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              height: 55,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),

                onPressed: login,

                child: const Text(
                  "Login",

                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) => const OwnerRegisterScreen(),
                  ),
                );
              },

              child: const Text("Create Pharmacy Account"),
            ),
          ],
        ),
      ),
    );
  }
}
