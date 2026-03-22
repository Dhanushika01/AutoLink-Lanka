import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'service_detail_screen.dart';
import '../utils/globals.dart';
import 'dart:io';
import 'my_bookings_screen.dart';
import 'saved_screen.dart';


class BookServiceScreen extends StatefulWidget {
  const BookServiceScreen({super.key});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

      
      // Listen to the exact same global location!
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
                        const Text('Book A Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        
                        // --- LIVE PROFILE AVATAR ---
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

                    TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: 'Search....',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        suffixIcon: const Icon(Icons.search, color: Colors.black, size: 28),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.black, width: 1.5)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.black, width: 1.5)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.black, width: 2)),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Near Your Area >', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        // This text updates automatically when you change it on the Home screen!
                        Text(currentLocation, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('service_centers').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.black));
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Text("No service centers found.");

                        // Filter by BOTH the text search AND the synced location!
                        var filteredDocs = snapshot.data!.docs.where((doc) {
                          String name = (doc['name'] ?? '').toString().toLowerCase();
                          String location = (doc['location'] ?? '').toString().toLowerCase();
                          
                          bool matchesSearch = name.contains(_searchQuery);
                          bool matchesLocation = location.contains(currentLocation.toLowerCase());
                          
                          return matchesSearch && matchesLocation;
                        }).toList();

                        if (filteredDocs.isEmpty) return Text("No results found in $currentLocation.");

                        return Column(
                          children: filteredDocs.map((doc) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => ServiceDetailScreen(
                                    centerId: doc.id,
                                    name: doc['name'] ?? '',
                                    location: doc['location'] ?? '',
                                    rating: doc['rating'] ?? 'N/A',
                                  ),
                                ));
                              },
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


  Widget _buildLargeCard(String title, String subtitle, String rating, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
              image: imageUrl.isNotEmpty ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) : null,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(rating, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
