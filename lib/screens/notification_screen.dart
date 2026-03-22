import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/globals.dart';
// Imports for the sidebar to work!
import 'main_screen.dart';
import 'my_bookings_screen.dart';
import 'saved_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  String _getDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) return 'Today';
    if (targetDate == yesterday) return 'Yesterday';
    
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      
      // --- THE FIXED SIDEBAR (DRAWER) ---
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.menu, color: Colors.black), onPressed: () => _scaffoldKey.currentState!.openDrawer()),
                    const Text('Notification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ValueListenableBuilder<String?>(
                      valueListenable: globalProfileImagePath,
                      builder: (context, imagePath, child) {
                        return CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: (imagePath != null && File(imagePath).existsSync()) ? FileImage(File(imagePath)) : null,
                          child: (imagePath == null || !File(imagePath).existsSync()) ? const Icon(Icons.person, size: 18, color: Colors.white) : null,
                        );
                      }
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('notifications').where('user_id', isEqualTo: userId).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.black));
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("You have no new notifications.", style: TextStyle(color: Colors.grey)));
                    }

                    var docs = snapshot.data!.docs;
                    docs.sort((a, b) {
                      Timestamp tA = a['created_at'] ?? Timestamp.now();
                      Timestamp tB = b['created_at'] ?? Timestamp.now();
                      return tB.compareTo(tA);
                    });

                    Map<String, List<QueryDocumentSnapshot>> groupedNotifications = {};
                    for (var doc in docs) {
                      Timestamp ts = doc['created_at'] ?? Timestamp.now();
                      String header = _getDateHeader(ts.toDate());
                      if (!groupedNotifications.containsKey(header)) groupedNotifications[header] = [];
                      groupedNotifications[header]!.add(doc);
                    }

                    List<Widget> uiElements = [];
                    groupedNotifications.forEach((header, notifs) {
                      uiElements.add(_buildDateHeader(header));
                      for (var doc in notifs) {
                        
                        // --- SWIPE TO DELETE LOGIC ---
                        uiElements.add(
                          Dismissible(
                            key: Key(doc.id),
                            direction: DismissDirection.endToStart, // Swipe right to left
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20.0),
                              decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) async {
                              // Deletes from Firebase!
                              await FirebaseFirestore.instance.collection('notifications').doc(doc.id).delete();
                            },
                            child: _buildNotificationCard(
                              isCancelled: doc['is_cancelled'] ?? false,
                              title: doc['title'] ?? 'Notification',
                              subtitle: doc['message'] ?? '',
                            ),
                          ),
                        );
                      }
                      uiElements.add(const SizedBox(height: 16));
                    });

                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: uiElements);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- THE FIXED DRAWER HELPER ---
  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context); // Closes the sidebar smoothly
        onTap(); // Executes the navigation
      },
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(padding: const EdgeInsets.only(bottom: 12.0), child: Text(date, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)));
  }

  Widget _buildNotificationCard({required bool isCancelled, required String title, required String subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
            child: Icon(isCancelled ? Icons.sentiment_dissatisfied : Icons.sentiment_satisfied_alt, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


