import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('bookings').where('user_id', isEqualTo: userId).snapshots(),
            builder: (context, snapshot) {
              int totalBookings = snapshot.hasData ? snapshot.data!.docs.length : 0;
              
              String currentTier = 'MEMBER';
              String nextTier = 'Silver';
              int nextGoal = 2;
              Color badgeColor = Colors.grey;

              if (totalBookings >= 50) {
                currentTier = 'PLATINUM';
                nextTier = 'Elite';
                nextGoal = 50; 
                badgeColor = Colors.blueAccent;
              } else if (totalBookings >= 20) {
                currentTier = 'GOLD';
                nextTier = 'Platinum';
                nextGoal = 50;
                badgeColor = Colors.amber;
              } else if (totalBookings >= 2) {
                currentTier = 'SILVER';
                nextTier = 'Gold';
                nextGoal = 20;
                badgeColor = Colors.blueGrey;
              }

              double progress = totalBookings >= 50 ? 1.0 : (totalBookings / nextGoal);
              int remaining = totalBookings >= 50 ? 0 : (nextGoal - totalBookings);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  
                  Icon(Icons.workspace_premium, size: 120, color: badgeColor),
                  const SizedBox(height: 16),
                  
                  Text(currentTier, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 24),

                  Stack(
                    children: [
                      Container(height: 24, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12))),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(height: 24, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    totalBookings >= 50 ? 'You have reached Elite Status!' : 'Book $remaining More Services to Get $nextTier', 
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 40),

                  // --- TIERS CONTAINER ---
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.grey.shade200)),
                    child: Column(
                      children: [
                        _buildTierRow(Icons.workspace_premium, 'Silver', 'Book 2 Services to get Silver', Colors.blueGrey),
                        const Divider(height: 32),
                        _buildTierRow(Icons.workspace_premium, 'Gold', 'Book 20 Services to get Gold', Colors.amber),
                        const Divider(height: 32),
                        _buildTierRow(Icons.workspace_premium, 'Platinum', 'Book 50 Services to get Platinum', Colors.blueAccent),
                      ],
                    ),
                  )
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _buildTierRow(IconData icon, String title, String subtitle, Color badgeColor) {
    return Row(
      children: [
        Icon(icon, size: 50, color: badgeColor),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: badgeColor)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

