import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'home_screen.dart';
import 'book_service_screen.dart';
import 'notification_screen.dart';
import 'login_screen.dart';
import 'loyalty_screen.dart';
import '../utils/globals.dart';
import 'my_bookings_screen.dart';
import 'saved_screen.dart';


class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  
  File? _localProfileImage; // Holds the image file from the device

  @override
  void initState() {
    super.initState();
    _loadLocalImage(); // Load the saved image when the screen opens
  }

  // --- LOCAL DEVICE STORAGE LOGIC ---
  Future<void> _loadLocalImage() async {
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    // Look for the image path saved specifically for this user
    String? imagePath = prefs.getString('profile_pic_$userId');
    
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _localProfileImage = File(imagePath);
      });
    }
  }

  Future<void> _pickAndSaveImageLocally() async {
    if (userId == null) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // 1. Save the file path to the device's local memory
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_pic_$userId', image.path);
      
      // 2. Update the global state so ALL screens change instantly!
      globalProfileImagePath.value = image.path; 
    }
  }


  // --- RENAME LOGIC (Still uses Firestore) ---
  void _editName(String currentName) {
    TextEditingController nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Name', style: TextStyle(fontWeight: FontWeight.bold)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty && userId != null) {
                  await FirebaseFirestore.instance.collection('users').doc(userId).update({
                    'name': nameController.text.trim(),
                  });
                }
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- LOGOUT LOGIC ---
  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out of AutoLink?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
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
    String userEmail = FirebaseAuth.instance.currentUser?.email ?? 'user@gmail.com';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      // --- COPY THIS OVER THE OLD DRAWER ---
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(decoration: const BoxDecoration(color: Colors.white), child: Center(child: Image.asset('assets/images/logo.png', height: 60))),
            _buildDrawerItem(context, Icons.home_outlined, 'Home', () => globalTabIndex.value = 0),
            _buildDrawerItem(context, Icons.list_alt, 'My Bookings', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen()))),
            _buildDrawerItem(context, Icons.notifications_none, 'Notifications', () => globalTabIndex.value = 2),
            _buildDrawerItem(context, Icons.bookmark_border, 'Saved', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedScreen()))),
            _buildDrawerItem(context, Icons.person_outline, 'Profile', () => globalTabIndex.value = 3),
          ],
        ),
      ),

      
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // --- LIVE USER DATA STREAM (Name from DB, Image from Device) ---
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
                  builder: (context, userSnapshot) {
                    String displayName = 'Loading...';

                    if (userSnapshot.hasData && userSnapshot.data!.exists) {
                      var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                      displayName = userData['name'] ?? 'Unknown User';
                    }

                    return Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey.shade300,
                              // Load the local file if it exists!
                              backgroundImage: _localProfileImage != null ? FileImage(_localProfileImage!) : null,
                              child: _localProfileImage == null 
                                ? const Icon(Icons.person, size: 60, color: Colors.white) 
                                : null,
                            ),
                            GestureDetector(
                              onTap: _pickAndSaveImageLocally,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                child: const Icon(Icons.add_a_photo, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(displayName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _editName(displayName),
                              child: const Icon(Icons.edit_outlined, size: 20, color: Colors.black87),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                ),
                const SizedBox(height: 4),
                Text(userEmail, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                const SizedBox(height: 32),

                // --- LIVE LOYALTY SHORTCUT CARD ---
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('bookings').where('user_id', isEqualTo: userId).snapshots(),
                  builder: (context, snapshot) {
                    int totalBookings = snapshot.hasData ? snapshot.data!.docs.length : 0;
                    
                    String currentTier = 'MEMBER';
                    String nextTier = 'Silver';
                    int nextGoal = 2;
                    Color badgeColor = Colors.grey;

                    if (totalBookings >= 50) {
                      currentTier = 'PLATINUM';
                      nextTier = 'Elite';
                      nextGoal = 50; 
                      badgeColor = Colors.blueAccent;
                    } else if (totalBookings >= 20) {
                      currentTier = 'GOLD';
                      nextTier = 'Platinum';
                      nextGoal = 50;
                      badgeColor = Colors.amber;
                    } else if (totalBookings >= 2) {
                      currentTier = 'SILVER';
                      nextTier = 'Gold';
                      nextGoal = 20;
                      badgeColor = Colors.blueGrey;
                    }

                    double progress = totalBookings >= 50 ? 1.0 : (totalBookings / nextGoal);
                    int remaining = totalBookings >= 50 ? 0 : (nextGoal - totalBookings);

                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoyaltyScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(24)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(currentTier, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                                Icon(Icons.workspace_premium, color: badgeColor, size: 40),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              totalBookings >= 50 ? 'You have reached the highest tier!' : 'Book $remaining More Services to Get $nextTier',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Stack(
                              children: [
                                Container(height: 16, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10))),
                                FractionallySizedBox(
                                  widthFactor: progress,
                                  child: Container(height: 16, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10))),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.grey, thickness: 1),
                const SizedBox(height: 16),

                // --- MENU OPTIONS ---
                _buildMenuRow(Icons.shield_outlined, 'Privacy And Security', () {}),
                _buildMenuRow(Icons.credit_card, 'Payment Method', () {}),
                _buildMenuRow(Icons.help_outline, 'Help & Support', () {}),
                _buildMenuRow(Icons.outlined_flag, 'Report a problem', () {}),
                _buildMenuRow(Icons.logout, 'Log out', _logout), 
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- COPY THIS OVER THE OLD HELPER METHOD AT THE BOTTOM OF THE FILE ---
  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context); 
        onTap(); 
      },
    );
  }


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
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
