import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added for User ID
import 'service_detail_screen.dart';
import 'ai_chatbot_screen.dart';
import '../utils/globals.dart';
import 'dart:io';
import 'my_bookings_screen.dart';
import 'saved_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String? userId = FirebaseAuth.instance.currentUser?.uid; // Get logged in user

    @override
  void initState() {
    super.initState();
    loadGlobalProfileImage(); // Loads the saved picture on startup!
  }

  void _changeLocation() {
    TextEditingController locationController = TextEditingController(text: globalLocation.value);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Your Location', style: TextStyle(fontWeight: FontWeight.bold)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: TextField(
            controller: locationController,
            decoration: InputDecoration(
              hintText: 'e.g., Kaduwela, Colombo',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                globalLocation.value = locationController.text.trim();
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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

      
      body: ValueListenableBuilder<String>(
        valueListenable: globalLocation,
        builder: (context, currentLocation, child) {
          return SingleChildScrollView(
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
                        const Text('AutoLink', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        // Listens for profile picture changes!
ValueListenableBuilder<String?>(
  valueListenable: globalProfileImagePath,
  builder: (context, imagePath, child) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.grey.shade300,
      backgroundImage: (imagePath != null && File(imagePath).existsSync()) 
          ? FileImage(File(imagePath)) 
          : null,
      child: (imagePath == null || !File(imagePath).existsSync()) 
          ? const Icon(Icons.person, size: 18, color: Colors.white) 
          : null,
    );
  }
),

                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- LIVE TOP CARD ---
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('service_centers').snapshots(),
                      builder: (context, snapshot) {
                        int nearbyCount = 0;
                        if (snapshot.hasData) {
                          nearbyCount = snapshot.data!.docs.where((doc) {
                            String loc = (doc['location'] ?? '').toString().toLowerCase();
                            return loc.contains(currentLocation.toLowerCase());
                          }).length;
                        }

                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(24)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: _changeLocation,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(currentLocation, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue)),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.location_on, size: 18, color: Colors.blue),
                                  ],
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(nearbyCount.toString(), style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w500, height: 1)),
                                  const SizedBox(width: 8),
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 10.0),
                                    child: Text('Service Centers Nearby', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                    ),
                    const SizedBox(height: 24),

                    // --- LIVE USER BOOKINGS STREAM (Powers Loyalty & History) ---
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('bookings')
                          .where('user_id', isEqualTo: userId)
                          .snapshots(),
                      builder: (context, bookingSnapshot) {
                        int totalBookings = bookingSnapshot.hasData ? bookingSnapshot.data!.docs.length : 0;
                        
                        // Calculate Loyalty Progress!
                        double progressPercentage = 0.0;
                        if (totalBookings < 2) {
                          progressPercentage = totalBookings / 2; // Toward Silver
                        } else if (totalBookings < 20) {
                          progressPercentage = totalBookings / 20; // Toward Gold
                        } else if (totalBookings < 50) {
                          progressPercentage = totalBookings / 50; // Toward Platinum
                        } else {
                          progressPercentage = 1.0; // Maxed out!
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. LOYALTY PROGRESS BAR
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 36,
                                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(18)),
                                    child: Stack(
                                      children: [
                                        // The Black Fill based on real math!
                                        FractionallySizedBox(
                                          widthFactor: progressPercentage,
                                          child: Container(
                                            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(18)),
                                          ),
                                        ),
                                        const Align(
                                          alignment: Alignment.centerRight, 
                                          child: Padding(padding: EdgeInsets.only(right: 12.0), child: Icon(Icons.flag_outlined, size: 20, color: Colors.grey))
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AiChatbotScreen())),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: Colors.grey.shade300, width: 1.5)),
                                    child: const Icon(Icons.auto_awesome, color: Colors.black, size: 22),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // 2. PREVIOUS BOOKINGS
                            const Row(
                              children: [
                                Text('Previous Bookings ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Icon(Icons.arrow_forward_ios, size: 14),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 130, 
                              child: bookingSnapshot.hasData && bookingSnapshot.data!.docs.isNotEmpty
                                ? ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: bookingSnapshot.data!.docs.map((doc) {
                                      String centerName = doc['center_name'] ?? 'Unknown Garage';
                                      Timestamp? dateTs = doc['date'] as Timestamp?;
                                      String dateStr = dateTs != null ? "${dateTs.toDate().day}/${dateTs.toDate().month}/${dateTs.toDate().year}" : 'No Date';
                                      
                                      return _buildSmallCard(centerName, dateStr);
                                    }).toList(),
                                  )
                                : const Text('No past bookings yet. Book a service below!', style: TextStyle(color: Colors.grey)),
                            ),
                          ],
                        );
                      }
                    ),
                    const SizedBox(height: 32),

                    // --- EXPLORE MORE ---
                    const Row(
                      children: [
                        Text('Explore More ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Icon(Icons.arrow_forward_ios, size: 14),
                      ],
                    ),
                    const SizedBox(height: 16),

                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('service_centers').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.black));
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Text("No service centers found.");

                        return Column(
                          children: snapshot.data!.docs.map((doc) {
                            return GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceDetailScreen(centerId: doc.id, name: doc['name'] ?? '', location: doc['location'] ?? '', rating: doc['rating'] ?? 'N/A'))),
                              child: _buildLargeCard(doc['name'] ?? '', doc['location'] ?? '', doc['rating'] ?? 'N/A', doc['image_url'] ?? ''),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }
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


  Widget _buildSmallCard(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 100, height: 80, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 8),
          SizedBox(width: 100, child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLargeCard(String title, String subtitle, String rating, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity, height: 160,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(20), image: imageUrl.isNotEmpty ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) : null),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              Row(children: [const Icon(Icons.star, color: Colors.amber, size: 18), const SizedBox(width: 4), Text(rating, style: const TextStyle(fontWeight: FontWeight.bold))])
            ],
          )
        ],
      ),
    );
  }
}
