import 'package:flutter/material.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, 'Privacy & Security'),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildToggleRow('Biometric Login', 'Use Face ID or Fingerprint', true),
          const Divider(height: 32),
          _buildToggleRow('Two-Factor Authentication', 'Add an extra layer of security', false),
          const Divider(height: 32),
          _buildToggleRow('Data Sharing', 'Share usage data to improve AutoLink', true),
          const SizedBox(height: 40),
          const Text('Privacy Policy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text(
            'At AutoLink, we take your privacy seriously. Your personal information, vehicle details, and booking history are encrypted and stored securely. We never sell your data to third parties.',
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String title, String subtitle, bool initialValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        Switch(
          value: initialValue,
          onChanged: (val) {},
          activeColor: Colors.black,
        ),
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