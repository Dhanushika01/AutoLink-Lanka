import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  double _getCircle1Top() {
    if (_currentPage == 0) return 400;
    if (_currentPage == 1) return 200;
    if (_currentPage == 2) return 500;
    return 100;
  }

  double _getCircle1Left() {
    if (_currentPage == 0) return -100;
    if (_currentPage == 1) return -150;
    if (_currentPage == 2) return -50;
    return -100;
  }

  double _getCircle2Top() {
    if (_currentPage == 0) return 600;
    if (_currentPage == 1) return 650;
    if (_currentPage == 2) return 400;
    return 550;
  }

  double _getCircle2Right() {
    if (_currentPage == 0) return -100;
    if (_currentPage == 1) return -50;
    if (_currentPage == 2) return -150;
    return -80;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            top: _getCircle1Top(),
            left: _getCircle1Left(),
            child: Hero(
              tag: 'circle1', // Connects to the Top Right circle on Login
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            top: _getCircle2Top(),
            right: _getCircle2Right(),
            child: Hero(
              tag: 'circle2', // Connects to the Bottom Left circle on Login
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // ... The rest of your SafeArea and PageView code stays exactly the same
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset('assets/images/logo.png', height: 60),
                
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      _buildPage(context, title: 'Welcome!'),
                      _buildPage(
                        context,
                        title: 'Book Any Service Center for\nYour Vehicle Easy',
                        imagePath: 'assets/images/intro1.png', 
                      ),
                      _buildPage(
                        context,
                        title: 'Booking A Service Never\nBeen This Fast!',
                        imagePath: 'assets/images/intro2.png',
                      ),
                      _buildPage(context, title: 'Are You Ready!'),
                    ],

                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0, right: 24.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(
                      backgroundColor: Colors.black,
                      shape: const CircleBorder(),
                      onPressed: () {
                        if (_currentPage == 3) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, {required String title, String? imagePath}) {
    if (imagePath == null) {
      // Layout for "Welcome!" and "Are You Ready!" (Centered vertically)
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 34, // Slightly larger to match your design
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      );
    } else {
      // Layout for the pages with the car illustrations
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 60), // Pushes text down from the top logo
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.3,
              ),
            ),
            const Spacer(), // Creates flexible space to push the image down
            Image.asset(
              imagePath,
              // Make the image take up 90% of the screen width so it's large and clear!
              width: MediaQuery.of(context).size.width * 0.9, 
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 100), // Keeps the image safely above the Next button
          ],
        ),
      );
    }
  }
}
