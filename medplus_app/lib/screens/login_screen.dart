import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  Future<void> login() async {
    final response = await http.post(
      Uri.parse("http://127.0.0.1:8000/login"),

      headers: {"Content-Type": "application/json"},

      body: jsonEncode({
        "email": emailController.text,

        "password": passwordController.text,
      }),
    );

    final data = jsonDecode(response.body);

    if (data["message"] == "Login successful") {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString("token", data["token"]);

      await prefs.setString("name", data["name"]);

      Navigator.pushReplacement(
        context,

        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(data["message"])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),

      body: Stack(
        children: [
          // BACKGROUND IMAGE
          Positioned.fill(
            child: Image.network(
              "https://images.unsplash.com/photo-1585435557343-3b092031d4f7",

              fit: BoxFit.cover,
            ),
          ),

          // DARK OVERLAY
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.72)),
          ),

          // CONTENT
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),

                child: Column(
                  children: [
                    // LOGO
                    Container(
                      padding: const EdgeInsets.all(22),

                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),

                        shape: BoxShape.circle,

                        border: Border.all(color: Colors.green, width: 2),
                      ),

                      child: const Icon(
                        Icons.local_pharmacy,

                        size: 60,

                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "Welcome Back",

                      style: TextStyle(
                        color: Colors.white,

                        fontSize: 38,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Your health journey starts here",

                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),

                    const SizedBox(height: 40),

                    // GLASS LOGIN CARD
                    Container(
                      padding: const EdgeInsets.all(28),

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),

                        borderRadius: BorderRadius.circular(32),

                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),

                            blurRadius: 30,

                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          // EMAIL
                          TextField(
                            controller: emailController,

                            style: const TextStyle(color: Colors.white),

                            decoration: InputDecoration(
                              hintText: "Email",

                              hintStyle: const TextStyle(color: Colors.white38),

                              prefixIcon: const Icon(
                                Icons.email,

                                color: Colors.green,
                              ),

                              filled: true,

                              fillColor: const Color(0xFF171C2A),

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),

                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // PASSWORD
                          TextField(
                            controller: passwordController,

                            obscureText: true,

                            style: const TextStyle(color: Colors.white),

                            decoration: InputDecoration(
                              hintText: "Password",

                              hintStyle: const TextStyle(color: Colors.white38),

                              prefixIcon: const Icon(
                                Icons.lock,

                                color: Colors.green,
                              ),

                              filled: true,

                              fillColor: const Color(0xFF171C2A),

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),

                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // LOGIN BUTTON
                          SizedBox(
                            width: double.infinity,

                            height: 62,

                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),

                                elevation: 12,
                              ),

                              onPressed: login,

                              child: const Text(
                                "Login",

                                style: TextStyle(
                                  color: Colors.white,

                                  fontSize: 22,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // HEALTH QUOTE
                          Container(
                            padding: const EdgeInsets.all(18),

                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.12),

                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: const Column(
                              children: [
                                Text(
                                  "💊 Daily Health Thought",

                                  style: TextStyle(
                                    color: Colors.green,

                                    fontWeight: FontWeight.bold,

                                    fontSize: 16,
                                  ),
                                ),

                                SizedBox(height: 10),

                                Text(
                                  "“The greatest wealth is health.”",

                                  textAlign: TextAlign.center,

                                  style: TextStyle(
                                    color: Colors.white70,

                                    height: 1.5,

                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // CREATE ACCOUNT
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },

                      child: const Text(
                        "Create Account",

                        style: TextStyle(
                          color: Colors.green,

                          fontSize: 18,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
