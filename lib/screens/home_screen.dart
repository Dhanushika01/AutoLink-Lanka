import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'service_detail_screen.dart';
import 'book_service_screen.dart';
import 'notification_screen.dart';
import 'account_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
                          'AutoLink',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/100'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Colombo', style: TextStyle(fontWeight: FontWeight.w500)),
                              SizedBox(width: 4),
                              Icon(Icons.location_on_outlined, size: 18),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const [
                              Text(
                                '24',
                                style: TextStyle(fontSize: 64, fontWeight: FontWeight.w500, height: 1),
                              ),
                              SizedBox(width: 8),
                              Padding(
                                padding: EdgeInsets.only(bottom: 10.0),
                                child: Text(
                                  'Service Centers Nearby',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.45, 
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                const Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 12.0),
                                    child: Icon(Icons.flag_outlined, size: 20, color: Colors.grey),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('AI Chatbot launching soon!')),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300, width: 1.5),
                            ),
                            child: const Icon(Icons.star_border, color: Colors.black, size: 22),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    const Row(
                      children: [
                        Text(
                          'Previous Bookings ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 14),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 130, 
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildSmallCard('Red Service Center', 'Malabe'),
                          _buildSmallCard('Vanilla Service Center', 'Kaduwela'),
                          _buildSmallCard('LOL Service Center', 'Battaramulla'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    const Row(
                      children: [
                        Text(
                          'Explore More ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 14),
                      ],
                    ),
                    const SizedBox(height: 16),

                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('service_centers').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Colors.black));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text("No service centers found near you.");
                        }

                        return Column(
                          children: snapshot.data!.docs.map((doc) {
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
                      _buildNavItem(Icons.home, 'Home', true),
                      _buildNavItem(Icons.home, 'Home', true),

                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) => const BookServiceScreen(),
                              transitionDuration: Duration.zero,
                            ),
                          );
                        },
                        child: _buildNavItem(Icons.calendar_today_outlined, 'Book', false),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, a1, a2) => const NotificationScreen(),
                              transitionDuration: Duration.zero, 
                            ),
                          );
                        },
                        child: _buildNavItem(Icons.notifications_none, 'Notification', false),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, a1, a2) => const AccountScreen(),
                              transitionDuration: Duration.zero, 
                            ),
                          );
                        },
                        child: _buildNavItem(Icons.person_outline, 'Account', false),
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

  Widget _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () {},
    );
  }

  Widget _buildSmallCard(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLargeCard(String title, String subtitle, String rating) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
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
