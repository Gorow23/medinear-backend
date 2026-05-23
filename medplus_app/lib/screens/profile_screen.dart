import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'owner_login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1115),

        elevation: 0,

        title: const Text(
          "Profile",

          style: TextStyle(
            color: Colors.white,

            fontSize: 28,

            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // PROFILE CARD
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(24),

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

              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,

                    backgroundColor: Colors.green,

                    backgroundImage: const NetworkImage(
                      "https://images.unsplash.com/photo-1500648767791-00dcc994a43d",
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Gaurav",

                    style: TextStyle(
                      color: Colors.white,

                      fontSize: 28,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Premium Member",

                    style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: const Text(
                      "Fast Medicine Delivery Enabled",

                      style: TextStyle(
                        color: Colors.green,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            buildTile(
              context: context,

              icon: Icons.location_on,

              title: "Saved Addresses",

              subtitle: "Manage delivery locations",
            ),

            buildTile(
              context: context,

              icon: Icons.receipt_long,

              title: "My Orders",

              subtitle: "Track previous orders",
            ),

            buildTile(
              context: context,

              icon: Icons.store,

              title: "Nearby Pharmacies",

              subtitle: "View nearby medicine stores",
            ),

            buildTile(
              context: context,

              icon: Icons.favorite,

              title: "Saved Medicines",

              subtitle: "Quick reorder medicines",
            ),

            // OWNER PORTAL
            buildTile(
              context: context,

              icon: Icons.local_hospital,

              title: "Pharmacy Partner Portal",

              subtitle: "Login as pharmacy owner",

              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(builder: (_) => OwnerLoginScreen()),
                );
              },
            ),

            buildTile(
              context: context,

              icon: Icons.settings,

              title: "Settings",

              subtitle: "Notifications & preferences",
            ),

            const SizedBox(height: 30),

            // PREMIUM CARD
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C853), Color(0xFF009624)],
                ),

                borderRadius: BorderRadius.circular(28),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Upgrade To Med Plus Premium",

                    style: TextStyle(
                      color: Colors.white,

                      fontSize: 24,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Get faster deliveries, priority support and exclusive pharmacy discounts.",

                    style: TextStyle(color: Colors.white70, height: 1.5),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,

                      foregroundColor: Colors.green,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),

                    onPressed: () {},

                    child: const Text(
                      "Upgrade Now",

                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // LOGOUT
            SizedBox(
              width: double.infinity,

              height: 60,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                onPressed: () {
                  Navigator.pushReplacement(
                    context,

                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },

                child: const Text(
                  "Logout",

                  style: TextStyle(
                    color: Colors.white,

                    fontSize: 18,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTile({
    required BuildContext context,

    required IconData icon,

    required String title,

    required String subtitle,

    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        margin: const EdgeInsets.only(bottom: 18),

        decoration: BoxDecoration(
          color: const Color(0xFF1A1D24),

          borderRadius: BorderRadius.circular(24),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),

              blurRadius: 15,

              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: ListTile(
          contentPadding: const EdgeInsets.all(18),

          leading: Container(
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),

              borderRadius: BorderRadius.circular(18),
            ),

            child: Icon(icon, color: Colors.green, size: 28),
          ),

          title: Text(
            title,

            style: const TextStyle(
              color: Colors.white,

              fontSize: 20,

              fontWeight: FontWeight.bold,
            ),
          ),

          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),

            child: Text(
              subtitle,

              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),

          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
        ),
      ),
    );
  }
}
