import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, 'Help & Support'),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text('Frequently Asked Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildFAQ('How do I cancel a booking?', 'You can manage and cancel your bookings from the "My Bookings" tab in the side menu.'),
          const Divider(height: 32),
          _buildFAQ('How does the Loyalty program work?', 'Every booking earns you progress! Reach 2 for Silver, 20 for Gold, and 50 for Platinum.'),
          const Divider(height: 32),
          _buildFAQ('Is my payment information safe?', 'Yes. We use industry-standard encryption and never store your full credit card details on our servers.'),
          const SizedBox(height: 40),
          const Text('Contact Us', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildContactRow(Icons.email_outlined, 'support@autolink.com'),
          const SizedBox(height: 16),
          _buildContactRow(Icons.phone_outlined, '+94 11 234 5678'),
        ],
      ),
    );
  }

  Widget _buildFAQ(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(answer, style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.5)),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.black),
        ),
        const SizedBox(width: 16),
        Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String title) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18), onPressed: () => Navigator.pop(context)),
        ),
      ),
    );
  }
}
