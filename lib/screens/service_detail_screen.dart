import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'booking_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String centerId;
  final String name;
  final String location;
  final String rating;

  const ServiceDetailScreen({
    super.key,
    required this.centerId,
    required this.name,
    required this.location,
    required this.rating,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  bool _checkIfOpen(String openTime, String closeTime) {
    if (openTime.isEmpty || closeTime.isEmpty) return false;
    try {
      final now = TimeOfDay.now();
      final currentMinutes = now.hour * 60 + now.minute;
      
      final openParts = openTime.split(':');
      final closeParts = closeTime.split(':');
      final openMinutes = int.parse(openParts[0]) * 60 + int.parse(openParts[1]);
      final closeMinutes = int.parse(closeParts[0]) * 60 + int.parse(closeParts[1]);
      
      return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
    } catch (e) {
      return false;
    }
  }

  void _toggleSave(bool isSaved, Map<String, dynamic> centerData) async {
    if (userId == null) return;
    
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('saved_centers')
        .doc(widget.centerId);

    if (isSaved) {
      await docRef.delete();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from saved')));
    } else {
      await docRef.set({
        'center_id': widget.centerId,
        'name': widget.name,
        'location': widget.location,
        'rating': widget.rating,
        'image_url': centerData['image_url'] ?? '',
        'saved_at': FieldValue.serverTimestamp(),
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved successfully!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('service_centers').doc(widget.centerId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }
          var data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          String imageUrl = data['image_url'] ?? 'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?q=80&w=1000&auto=format&fit=crop';
          String phone = data['phone'] ?? '+94 000000000';
          String address = data['address'] ?? 'Address not available';
          String openTime = data['open_time'] ?? '09:00';
          String closeTime = data['close_time'] ?? '18:00';
          
          bool isOpen = _checkIfOpen(openTime, closeTime);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter, end: Alignment.topCenter,
                            colors: [Colors.white, Colors.white.withOpacity(0.0)],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50, left: 20,
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.8),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50, right: 20,
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId ?? 'guest')
                            .collection('saved_centers')
                            .doc(widget.centerId)
                            .snapshots(),
                        builder: (context, saveSnapshot) {
                          bool isSaved = saveSnapshot.hasData && saveSnapshot.data!.exists;
                          return CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.8),
                            child: IconButton(
                              icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, color: Colors.black, size: 22),
                              onPressed: () => _toggleSave(isSaved, data),
                            ),
                          );
                        }
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(widget.location, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookingScreen(
                                      centerId: widget.centerId,
                                      centerName: widget.name,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: const Text('Book', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              Share.share('Check out ${widget.name} on AutoLink!\n📍 $address\n📞 $phone');
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.ios_share, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text('Hours', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text('$openTime - $closeTime', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        isOpen ? 'Open Now' : 'Closed', 
                        style: TextStyle(fontSize: 14, color: isOpen ? Colors.green : Colors.red, fontWeight: FontWeight.w600)
                      ),
                      const SizedBox(height: 32),
                      const Text('Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      
                      const Text('Phone', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(phone, style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 24),

                      const Text('Address', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(address, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.5)),
                      const SizedBox(height: 40),

                      Center(
                        child: TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.report_problem_outlined, color: Colors.black),
                          label: const Text('Report an issue', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}
