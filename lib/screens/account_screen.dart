import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'book_service_screen.dart';
import 'notification_screen.dart';
import 'login_screen.dart';
import 'loyalty_screen.dart'; // Import the new Loyalty Screen!

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Firebase Logout Method
  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out of AutoLink?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await FirebaseAuth.instance.signOut(); // Tell Firebase to log out
              
              if (mounted) {
                // Send user back to the Login Screen and clear navigation history
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user's email to display
    String userEmail = FirebaseAuth.instance.currentUser?.email ?? 'johndoe@gmail.com';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      
      // --- THE SIDE MENU (DRAWER) ---
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.white),
              child: Center(
                child: Image.asset('assets/images/logo.png', height: 60),
              ),
            ),
            _buildDrawerItem(Icons.home_outlined, 'Home'),
            _buildDrawerItem(Icons.list_alt, 'My Bookings'),
            _buildDrawerItem(Icons.notifications_none, 'Notifications'),
            _buildDrawerItem(Icons.bookmark_border, 'Saved'),
            _buildDrawerItem(Icons.person_outline, 'Profile'),
          ],
        ),
      ),
      
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // --- PROFILE PICTURE & INFO ---
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade300,
                          // You can uncomment this when you have user image uploads!
                          // backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'John Doe', // You can fetch the real name from Firestore later
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.edit_outlined, size: 20, color: Colors.black87),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 32),

                    // --- LOYALTY SHORTCUT CARD ---
                    GestureDetector(
                      onTap: () {
                        // Navigate to the Loyalty Screen!
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoyaltyScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300, // Matches your flat grey design
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'PLATINUM',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                                ),
                                // Replace with your Image.asset badge when ready!
                                Icon(Icons.workspace_premium, color: Colors.blueAccent, size: 40),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Book 2 More Services to Get Elite',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            // Progress Bar
                            Stack(
                              children: [
                                Container(
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                Container(
                                  height: 16,
                                  width: MediaQuery.of(context).size.width * 0.45, // Simulates the progress fill
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.grey, thickness: 1),
                    const SizedBox(height: 16),

                    // --- CLEAN MENU OPTIONS ---
                    _buildMenuRow(Icons.shield_outlined, 'Privacy And Security', () {}),
                    _buildMenuRow(Icons.credit_card, 'Payment Method', () {}),
                    _buildMenuRow(Icons.help_outline, 'Help & Support', () {}),
                    _buildMenuRow(Icons.outlined_flag, 'Report a problem', () {}),
                    _buildMenuRow(Icons.person_add_alt_1_outlined, 'Add account', () {}),
                    _buildMenuRow(Icons.logout, 'Log out', _logout), // Triggers your Firebase logout!
                    
                    const SizedBox(height: 40), // Extra padding for scrolling past nav bar
                  ],
                ),
              ),
            ),
          ),

          // --- ACRYLIC BLUR BOTTOM NAVIGATION BAR ---
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), 
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7), 
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () => _navigateTo(context, const HomeScreen()),
                        child: _buildNavItem(Icons.home_outlined, 'Home', false),
                      ),
                      GestureDetector(
                        onTap: () => _navigateTo(context, const BookServiceScreen()),
                        child: _buildNavItem(Icons.calendar_today_outlined, 'Book', false),
                      ),
                      GestureDetector(
                        onTap: () => _navigateTo(context, const NotificationScreen()),
                        child: _buildNavItem(Icons.notifications_none, 'Notification', false),
                      ),
                      // Account Icon (Active)
                      _buildNavItem(Icons.person, 'Account', true),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER METHODS ---
  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, a1, a2) => screen,
        transitionDuration: Duration.zero, 
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () {},
    );
  }

  // New Menu Row Helper for the clean text+icon look
  Widget _buildMenuRow(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 28),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? Colors.black : Colors.black45, size: 26),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? Colors.black : Colors.black45,
          ),
        ),
      ],
    );
  }
}
