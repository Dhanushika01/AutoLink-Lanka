import 'package:flutter/material.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, 'Payment Method'),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Saved Cards', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.credit_card, color: Colors.white, size: 32),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•••• •••• •••• 4242', style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2)),
                      const SizedBox(height: 4),
                      Text('Expires 12/28', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.check_circle, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, color: Colors.black),
                label: const Text('Add New Card', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
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
