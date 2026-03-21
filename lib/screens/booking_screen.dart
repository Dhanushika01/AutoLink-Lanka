import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart'; // To navigate back after a successful booking

class BookingScreen extends StatefulWidget {
  final String centerId;
  final String centerName;

  const BookingScreen({
    super.key,
    required this.centerId,
    required this.centerName,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedVehicle;
  String? _selectedService;
  String? _selectedPayment;
  bool _isBooking = false;

  // Dropdown Options
  final List<String> _vehicles = ['Car', 'SUV', 'Van', 'Motorcycle'];
  final List<String> _services = ['Full Service', 'Body Wash', 'Oil Change', 'Repair'];
  final List<String> _payments = ['VISA', 'MasterCard', 'Cash on Arrival'];

  Future<void> _confirmBooking() async {
    if (_selectedVehicle == null || _selectedService == null || _selectedPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all the fields!')),
      );
      return;
    }

    setState(() => _isBooking = true);

    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      
      // Save to Firebase
      await FirebaseFirestore.instance.collection('bookings').add({
        'user_id': userId ?? 'guest_user',
        'center_id': widget.centerId,
        'center_name': widget.centerName,
        'date': _selectedDate,
        'vehicle_type': _selectedVehicle,
        'service_type': _selectedService,
        'payment_method': _selectedPayment,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
      });

      setState(() => _isBooking = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking Confirmed Successfully!')),
        );
        // Take them all the way back to the Home Screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isBooking = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Booking', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- CALENDAR CARD ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: CalendarDatePicker(
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onDateChanged: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),

              // --- VEHICLE DROPDOWN ---
              const Text('Select Vehicle Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              _buildDropdown(
                hint: 'Select The Vehicle',
                value: _selectedVehicle,
                items: _vehicles,
                onChanged: (val) => setState(() => _selectedVehicle = val),
                isDark: false,
              ),
              const SizedBox(height: 24),

              // --- SERVICE DROPDOWN ---
              const Text('Select Service Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              _buildDropdown(
                hint: 'Select The Type',
                value: _selectedService,
                items: _services,
                onChanged: (val) => setState(() => _selectedService = val),
                isDark: false,
              ),
              const SizedBox(height: 24),

              // --- PAYMENT DROPDOWN ---
              const Text('Select Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              _buildDropdown(
                hint: 'Select Method',
                value: _selectedPayment,
                items: _payments,
                onChanged: (val) => setState(() => _selectedPayment = val),
                isDark: true, // This triggers the black styling from your Figma design!
              ),
              const SizedBox(height: 40),

              // --- BOOK BUTTON ---
              ElevatedButton(
                onPressed: _isBooking ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isBooking
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'Book',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build the custom dropdowns matching your Figma file
  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required bool isDark,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      icon: Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white : Colors.black),
      dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.black,
        fontFamily: 'SFProRounded', // Ensures it matches your global font
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
        filled: true,
        fillColor: isDark ? Colors.black : Colors.grey.shade200,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
