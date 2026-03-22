import 'package:flutter/material.dart';
import 'dart:ui';
import 'home_screen.dart';
import 'book_service_screen.dart';
import 'notification_screen.dart';
import 'account_screen.dart';
import '../utils/globals.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  final List<Widget> _pages = const [
    HomeScreen(),
    BookServiceScreen(),
    NotificationScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ValueListenableBuilder<int>(
        valueListenable: globalTabIndex,
        builder: (context, currentIndex, child) {
          return Stack(
            children: [
              IndexedStack(
                index: currentIndex,
                children: _pages,
              ),
              Positioned(
                bottom: 24, left: 24, right: 24,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      height: 70,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(40), border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0, currentIndex),
                          _buildNavItem(Icons.calendar_today_outlined, Icons.calendar_today, 'Book', 1, currentIndex),
                          _buildNavItem(Icons.notifications_none, Icons.notifications, 'Notification', 2, currentIndex),
                          _buildNavItem(Icons.person_outline, Icons.person, 'Account', 3, currentIndex),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildNavItem(IconData outlineIcon, IconData solidIcon, String label, int index, int currentIndex) {
    bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () {
        globalTabIndex.value = index;
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isActive ? solidIcon : outlineIcon, color: isActive ? Colors.black : Colors.black45, size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: isActive ? Colors.black : Colors.black45)),
        ],
      ),
    );
  }
}
