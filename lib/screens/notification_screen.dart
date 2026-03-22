import 'package:flutter/material.dart';
import 'dart:ui';
import 'home_screen.dart';
import 'book_service_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
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
                          'Notification',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/100'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    _buildDateHeader('Today'),
                    _buildNotificationCard(
                      isCancelled: true,
                      title: 'Your Booking has been cancelled',
                      subtitle: 'All slots on Neon Services are temporarily closed on Mon - Fri until the Christmas',
                    ),
                    _buildNotificationCard(
                      isCancelled: false,
                      title: 'Your Booking Confirmed!',
                      subtitle: 'Your Neon Services Booking has been confirmed.',
                    ),
                    const SizedBox(height: 16),

                    _buildDateHeader('Yesterday'),
                    _buildNotificationCard(
                      isCancelled: true,
                      title: 'Your Booking has been cancelled',
                      subtitle: 'All slots on Neon Services are temporarily closed on Mon - Fri until the Christmas',
                    ),
                    _buildNotificationCard(
                      isCancelled: true,
                      title: 'Your Booking has been cancelled',
                      subtitle: 'All slots on Neon Services are temporarily closed on Mon - Fri until the Christmas',
                    ),
                    const SizedBox(height: 16),

                    _buildDateHeader('Dec 20, 2024'),
                    _buildNotificationCard(
                      isCancelled: true,
                      title: 'Your Booking has been cancelled',
                      subtitle: 'All slots on Neon Services are temporarily closed on Mon - Fri until the Christmas',
                    ),
                    const SizedBox(height: 16),
                    
                    _buildDateHeader('Dec 19, 2024'),
                    _buildNotificationCard(
                      isCancelled: true,
                      title: 'Your Booking has been cancelled',
                      subtitle: 'All slots on Neon Services are temporarily closed on Mon - Fri until the Christmas',
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
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, a1, a2) => const HomeScreen(),
                              transitionDuration: Duration.zero, 
                            ),
                          );
                        },
                        child: _buildNavItem(Icons.home_outlined, 'Home', false),
                      ),
                      
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, a1, a2) => const BookServiceScreen(),
                              transitionDuration: Duration.zero, 
                            ),
                          );
                        },
                        child: _buildNavItem(Icons.calendar_today_outlined, 'Book', false),
                      ),
                      
                      _buildNavItem(Icons.notifications, 'Notification', true),
                      _buildNavItem(Icons.person_outline, 'Account', false),
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

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        date,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNotificationCard({
    required bool isCancelled,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCancelled ? Icons.sentiment_dissatisfied : Icons.sentiment_satisfied_alt,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: Colors.grey, height: 1.4),
                ),
              ],
            ),
          ),
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
