import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

import 'cart_screen.dart';
import 'orders_screen.dart';
import 'owner_login_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();

  List medicines = [];

  List cart = [];

  double userLat = 0;

  double userLng = 0;

  Future<void> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition();

    userLat = position.latitude;

    userLng = position.longitude;
  }

  Future<void> searchMedicine() async {
    await getUserLocation();

    final name = searchController.text;

    final response = await http.get(
      Uri.parse(
        "http://localhost:8000/medicines/search?name=$name&user_lat=$userLat&user_lng=$userLng",
      ),
    );

    final data = jsonDecode(response.body);

    setState(() {
      medicines = data;
    });
  }

  void addToCart(Map medicine) {
    cart.add(medicine);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,

        content: Text("${medicine["name"]} added to cart"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // TOP BAR
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          "Stay Healthy 👋",

                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),

                        SizedBox(height: 6),

                        Text(
                          "Med Plus",

                          style: TextStyle(
                            color: Colors.white,

                            fontSize: 40,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        iconButton(Icons.receipt_long, () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) => const OrdersScreen(),
                            ),
                          );
                        }),

                        const SizedBox(width: 10),

                        iconButton(Icons.shopping_bag, () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) => CartScreen(cart: cart),
                            ),
                          );
                        }),

                        const SizedBox(width: 10),

                        iconButton(Icons.person, () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // SEARCH BAR
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF171C2A),

                    borderRadius: BorderRadius.circular(24),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.08),

                        blurRadius: 25,

                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: TextField(
                    controller: searchController,

                    style: const TextStyle(color: Colors.white),

                    decoration: InputDecoration(
                      hintText: "Search medicines...",

                      hintStyle: const TextStyle(color: Colors.white38),

                      prefixIcon: const Icon(
                        Icons.search,

                        color: Colors.white54,
                      ),

                      suffixIcon: IconButton(
                        onPressed: searchMedicine,

                        icon: const Icon(
                          Icons.arrow_forward,

                          color: Colors.green,
                        ),
                      ),

                      border: InputBorder.none,

                      contentPadding: const EdgeInsets.all(22),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // HERO
                Container(
                  height: 240,

                  width: double.infinity,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(34),

                    image: const DecorationImage(
                      image: NetworkImage(
                        "https://images.unsplash.com/photo-1584017911766-d451b3d0e843",
                      ),

                      fit: BoxFit.cover,
                    ),
                  ),

                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(34),

                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.75),

                          Colors.black.withOpacity(0.2),
                        ],

                        begin: Alignment.bottomLeft,

                        end: Alignment.topRight,
                      ),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(28),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        mainAxisAlignment: MainAxisAlignment.end,

                        children: [
                          const Text(
                            "Your Health,\nOur Priority",

                            style: TextStyle(
                              color: Colors.white,

                              fontSize: 36,

                              fontWeight: FontWeight.bold,

                              height: 1.2,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "Medicines delivered within 15 minutes at your doorstep.",

                            style: TextStyle(
                              color: Colors.white70,

                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,

                              vertical: 10,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.green,

                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: const Text(
                              "Healthy Living Starts Here",

                              style: TextStyle(
                                color: Colors.white,

                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                // QUOTE CARD
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(22),

                  decoration: BoxDecoration(
                    color: const Color(0xFF171C2A),

                    borderRadius: BorderRadius.circular(28),
                  ),

                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        "💡 Health Quote",

                        style: TextStyle(
                          color: Colors.green,

                          fontSize: 18,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 14),

                      Text(
                        "“Take care of your body. It’s the only place you have to live.”",

                        style: TextStyle(
                          color: Colors.white,

                          fontSize: 20,

                          height: 1.5,

                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                // CATEGORIES
                const Text(
                  "Categories",

                  style: TextStyle(
                    color: Colors.white,

                    fontSize: 28,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 120,

                  child: ListView(
                    scrollDirection: Axis.horizontal,

                    children: [
                      categoryCard("Fever", Icons.medication),

                      categoryCard("Diabetes", Icons.bloodtype),

                      categoryCard("Heart", Icons.favorite),

                      categoryCard("Vitamin", Icons.local_drink),

                      categoryCard("Cold", Icons.masks),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  "Nearby Medicines",

                  style: TextStyle(
                    color: Colors.white,

                    fontSize: 28,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                medicines.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(60),

                        child: Center(
                          child: Text(
                            "Search medicines to discover nearby pharmacies",

                            textAlign: TextAlign.center,

                            style: TextStyle(
                              color: Colors.white54,

                              fontSize: 18,
                            ),
                          ),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,

                        physics: const NeverScrollableScrollPhysics(),

                        itemCount: medicines.length,

                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,

                              crossAxisSpacing: 20,

                              mainAxisSpacing: 20,

                              childAspectRatio: 0.58,
                            ),

                        itemBuilder: (context, index) {
                          final medicine = medicines[index];

                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF171C2A),

                              borderRadius: BorderRadius.circular(28),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),

                                  blurRadius: 20,

                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Expanded(
                                  flex: 5,

                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(28),
                                    ),

                                    child: Image.network(
                                      medicine["image"] ??
                                          "https://images.unsplash.com/photo-1587854692152-cbe660dbde88",

                                      fit: BoxFit.cover,

                                      width: double.infinity,
                                    ),
                                  ),
                                ),

                                Expanded(
                                  flex: 5,

                                  child: Padding(
                                    padding: const EdgeInsets.all(14),

                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        Text(
                                          medicine["name"],

                                          maxLines: 1,

                                          overflow: TextOverflow.ellipsis,

                                          style: const TextStyle(
                                            color: Colors.white,

                                            fontSize: 20,

                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        Text(
                                          medicine["pharmacy"],

                                          style: TextStyle(
                                            color: Colors.grey.shade400,
                                          ),
                                        ),

                                        const SizedBox(height: 5),

                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on,

                                              color: Colors.red,

                                              size: 16,
                                            ),

                                            const SizedBox(width: 4),

                                            Text(
                                              medicine["location"],

                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 10),

                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,

                                            vertical: 6,
                                          ),

                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(
                                              0.15,
                                            ),

                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),

                                          child: Text(
                                            "${medicine["distance"]} km away",

                                            style: const TextStyle(
                                              color: Colors.green,

                                              fontWeight: FontWeight.bold,

                                              fontSize: 12,
                                            ),
                                          ),
                                        ),

                                        const Spacer(),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,

                                          children: [
                                            Text(
                                              "₹${medicine["price"]}",

                                              style: const TextStyle(
                                                color: Colors.white,

                                                fontSize: 24,

                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),

                                            GestureDetector(
                                              onTap: () {
                                                addToCart(medicine);
                                              },

                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  10,
                                                ),

                                                decoration: BoxDecoration(
                                                  color: Colors.green,

                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),

                                                child: const Icon(
                                                  Icons.add,

                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: const Color(0xFF171C2A),

          borderRadius: BorderRadius.circular(18),
        ),

        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }

  Widget categoryCard(String title, IconData icon) {
    return Container(
      width: 110,

      margin: const EdgeInsets.only(right: 18),

      decoration: BoxDecoration(
        color: const Color(0xFF171C2A),

        borderRadius: BorderRadius.circular(26),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(icon, color: Colors.green, size: 38),

          const SizedBox(height: 14),

          Text(
            title,

            style: const TextStyle(
              color: Colors.white,

              fontWeight: FontWeight.bold,

              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
