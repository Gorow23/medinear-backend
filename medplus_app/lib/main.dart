import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import 'screens/cart_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/owner_login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;

  bool loading = true;

  @override
  void initState() {
    super.initState();

    checkLogin();
  }

  Future<void> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString("token");

    if (token != null) {
      isLoggedIn = true;
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,

        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Med Plus',

      theme: ThemeData(
        primarySwatch: Colors.green,

        scaffoldBackgroundColor: const Color(0xFFF5F7FA),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,

          elevation: 0,

          centerTitle: false,

          iconTheme: IconThemeData(color: Colors.black),

          titleTextStyle: TextStyle(
            color: Colors.black,

            fontSize: 24,

            fontWeight: FontWeight.bold,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,

            foregroundColor: Colors.white,

            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),

      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),

      routes: {
        "/home": (context) => const HomeScreen(),

        "/register": (context) => const RegisterScreen(),

        "/owner-login": (context) => OwnerLoginScreen(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();

  List medicines = [];

  List cart = [];

  Future<void> searchMedicine() async {
    final name = searchController.text;

    if (name.isEmpty) return;

    final url = "http://127.0.0.1:8000/medicines/search?name=$name";

    try {
      final response = await http.get(Uri.parse(url));

      final data = jsonDecode(response.body);

      setState(() {
        medicines = data;
      });
    } catch (e) {
      print(e);
    }
  }

  void addToCart(Map medicine) {
    setState(() {
      cart.add(medicine);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${medicine["name"]} added to cart")),
    );
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    Navigator.pushReplacement(
      context,

      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Med Plus"),

        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),

            onPressed: () {
              Navigator.push(
                context,

                MaterialPageRoute(builder: (_) => CartScreen(cart: cart)),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.receipt_long),

            onPressed: () {
              Navigator.push(
                context,

                MaterialPageRoute(builder: (_) => OrdersScreen()),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.store),

            onPressed: () {
              Navigator.pushNamed(context, "/owner-login");
            },
          ),

          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),

      body: const Center(child: Text("Auto Login Enabled ✅")),
    );
  }
}
