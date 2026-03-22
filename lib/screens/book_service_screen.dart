import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'service_detail_screen.dart';
import 'home_screen.dart';
import 'notification_screen.dart';
import 'account_screen.dart';
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
            _buildDrawerItem(context, Icons.home_outlined, 'Home', const HomeScreen()),
            _buildDrawerItem(context, Icons.list_alt, 'My Bookings', const MyBookingsScreen()),
            _buildDrawerItem(context, Icons.notifications_none, 'Notifications', const NotificationScreen()),
            _buildDrawerItem(context, Icons.bookmark_border, 'Saved', const SavedScreen()),
            _buildDrawerItem(context, Icons.person_outline, 'Profile', const AccountScreen()),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.black),
                          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                        ),
                        const Text(
                          'Book A Service',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/100'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search....',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        suffixIcon: const Icon(Icons.search, color: Colors.black, size: 28),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Colors.black, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Colors.black, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Near Your Area >',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('service_centers').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Colors.black));
                        }
                        
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text("No service centers found.");
                        }

                        var filteredDocs = snapshot.data!.docs.where((doc) {
                          String name = (doc['name'] ?? '').toString().toLowerCase();
                          return name.contains(_searchQuery);
                        }).toList();

                        if (filteredDocs.isEmpty) {
                          return const Text("No results match your search.");
                        }

                        return Column(
                          children: filteredDocs.map((doc) {
                            String centerId = doc.id;
                            String name = doc['name'] ?? 'Unknown Center';
                            String location = doc['location'] ?? 'Unknown Location';
                            String rating = doc['rating'] ?? 'N/A';
                            
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ServiceDetailScreen(
                                      centerId: centerId,
                                      name: name,
                                      location: location,
                                      rating: rating,
                                    ),
                                  ),
                                );
                              },
                              child: _buildLargeCard(name, location, rating),
                            );
                          }).toList(),
                        );
                      },
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

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, Widget destination) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
      },
    );
  }


  Widget _buildLargeCard(String title, String subtitle, String rating) {
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
