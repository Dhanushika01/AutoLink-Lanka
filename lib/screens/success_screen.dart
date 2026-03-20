import 'package:flutter/material.dart';
import 'home_screen.dart'; // We'll navigate back to login after this

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top Left Grey Circle
          Positioned(
            top: 100,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          // Bottom Right Grey Circle
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo.png', height: 60),
                    const SizedBox(height: 40),
                    
                    const Text(
                      'Your Account Successfully\nCreated!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Next Button
                    FloatingActionButton(
                      backgroundColor: Colors.black,
                      shape: const CircleBorder(),
                      onPressed: () {
                        // Send them to the Login Screen to sign in with their new account!
                        Navigator.pushAndRemoveUntil(
                          context,
                          // Make sure to import 'home_screen.dart' at the top of the file!
MaterialPageRoute(builder: (context) => const HomeScreen()),

                          (route) => false, // This clears the navigation history so they can't hit "back" to the success screen
                        );
                      },
                      child: const Icon(Icons.arrow_forward_ios, color: Colors.white),
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
}
