import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'service_detail_screen.dart';
import 'ai_chatbot_screen.dart';
import '../utils/globals.dart';
import 'my_bookings_screen.dart';
import 'saved_screen.dart';
import 'loyalty_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String? userId = FirebaseAuth.instance.currentUser?.uid; 

  @override
  void initState() {
    super.initState();
    loadGlobalProfileImage(); 
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
          return SafeArea(
            bottom: false,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 80, bottom: 120, left: 24, right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
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
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200, 
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: _changeLocation,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(currentLocation, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87, fontSize: 13)),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.location_on_outlined, size: 16, color: Colors.black87), 
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      nearbyCount.toString(), 
                                      style: const TextStyle(fontSize: 100, fontWeight: FontWeight.w300, height: 0.9)
                                    ), 
                                    const SizedBox(width: 12),
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 16.0),
                                      child: Text(
                                        'Service Centers Nearby', 
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }
                      ),
                      const SizedBox(height: 24),

                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('bookings').where('user_id', isEqualTo: userId).snapshots(),
                        builder: (context, bookingSnapshot) {
                          int totalBookings = bookingSnapshot.hasData ? bookingSnapshot.data!.docs.length : 0;
                          
                          double progressPercentage = 0.0;
                          if (totalBookings < 2) progressPercentage = totalBookings / 2;
                          else if (totalBookings < 20) progressPercentage = totalBookings / 20;
                          else if (totalBookings < 50) progressPercentage = totalBookings / 50;
                          else progressPercentage = 1.0; 

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoyaltyScreen())),
                                      child: Container(
                                        height: 48, 
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200, 
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        child: Stack(
                                          children: [
                                            FractionallySizedBox(
                                              widthFactor: progressPercentage,
                                              child: Container(
                                                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(24)),
                                              ),
                                            ),
                                            const Align(
                                              alignment: Alignment.centerRight, 
                                              child: Padding(padding: EdgeInsets.only(right: 16.0), child: Icon(Icons.flag_outlined, size: 22, color: Colors.grey))
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  GestureDetector(
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AiChatbotScreen())),
                                    child: Container(
                                      height: 48,
                                      width: 48,
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
                                      child: const Icon(Icons.auto_awesome, color: Colors.black, size: 22),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),

                              const Text('Previous Bookings >', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 20),
                              
                              SizedBox(
                                height: 190, 
                                child: bookingSnapshot.hasData && bookingSnapshot.data!.docs.isNotEmpty
                                  ? ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: bookingSnapshot.data!.docs.map((doc) {
                                        var data = doc.data() as Map<String, dynamic>;
                                        String centerId = data['center_id'] ?? '';
                                        String centerName = data['center_name'] ?? 'Unknown Garage';
                                        Timestamp? dateTs = data['date'] as Timestamp?;
                                        String dateStr = dateTs != null ? "${dateTs.toDate().day}/${dateTs.toDate().month}/${dateTs.toDate().year}" : 'No Date';
                                        
                                        String rawImageUrl = data.containsKey('image_url') ? data['image_url'] : '';
                                        String finalImageUrl = rawImageUrl.isNotEmpty 
                                            ? rawImageUrl 
                                            : 'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?q=80&w=1000&auto=format&fit=crop';

                                        return GestureDetector(
                                          onTap: () {
                                            if (centerId.isNotEmpty) {
                                              Navigator.push(context, MaterialPageRoute(
                                                builder: (context) => ServiceDetailScreen(
                                                  centerId: centerId,
                                                  name: centerName,
                                                  location: 'View Details',
                                                  rating: '4.9',
                                                )
                                              ));
                                            }
                                          },
                                          child: _buildSmallCard(centerName, dateStr, finalImageUrl),
                                        );
                                      }).toList(),
                                    )
                                  : const Text('No past bookings yet.', style: TextStyle(color: Colors.grey)),
                              ),
                            ],
                          );
                        }
                      ),
                      const SizedBox(height: 24),

                      const Text('Explore More >', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),

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

                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        color: Colors.white.withOpacity(0.8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.menu, color: Colors.black), 
                              onPressed: () => _scaffoldKey.currentState!.openDrawer()
                            ),
                            const Text('AutoLink', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ValueListenableBuilder<String?>(
                              valueListenable: globalProfileImagePath,
                              builder: (context, imagePath, child) {
                                return CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.grey.shade200, 
                                  backgroundImage: (imagePath != null && File(imagePath).existsSync()) ? FileImage(File(imagePath)) : null,
                                  child: (imagePath == null || !File(imagePath).existsSync()) ? const Icon(Icons.person, size: 18, color: Colors.grey) : null,
                                );
                              }
                            ),
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
      ),
    );
  }

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

  Widget _buildSmallCard(String title, String subtitle, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 140, 
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey.shade200, 
              borderRadius: BorderRadius.circular(20),
              image: imageUrl.isNotEmpty 
                  ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) 
                  : null, 
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 140, 
            child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildLargeCard(String title, String subtitle, String rating, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity, height: 180, 
            decoration: BoxDecoration(
              color: Colors.grey.shade200, 
              borderRadius: BorderRadius.circular(24), 
              image: imageUrl.isNotEmpty ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) : null
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
