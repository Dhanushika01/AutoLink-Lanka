import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _cardNumberController = TextEditingController();
  final _expController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isSaving = false;

  Future<void> _saveCard() async {
    if (_cardNumberController.text.length < 4 || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in valid card details.')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      String last4 = _cardNumberController.text.substring(_cardNumberController.text.length - 4);

      await FirebaseFirestore.instance.collection('saved_cards').add({
        'user_id': userId,
        'last4': last4,
        'exp': _expController.text,
        'name': _nameController.text,
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
        title: const Text('Add New Card', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18), onPressed: () => Navigator.pop(context)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.contactless_outlined, color: Colors.white, size: 32),
                  const Spacer(),
                  Text(
                    _cardNumberController.text.isEmpty ? '•••• •••• •••• ••••' : _cardNumberController.text,
                    style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_nameController.text.isEmpty ? 'CARDHOLDER' : _nameController.text.toUpperCase(), style: const TextStyle(color: Colors.grey)),
                      Text(_expController.text.isEmpty ? 'MM/YY' : _expController.text, style: const TextStyle(color: Colors.white)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            _buildTextField('Cardholder Name', _nameController, TextInputType.name, false),
            const SizedBox(height: 16),
            _buildTextField(
              'Card Number', 
              _cardNumberController, 
              TextInputType.number, 
              false, 
              formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16)]
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'Expiry Date (MM/YY)', 
                    _expController, 
                    TextInputType.number, 
                    false, 
                    formatters: [FilteringTextInputFormatter.digitsOnly, ExpiryDateFormatter()]
                  )
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    'CVV', 
                    _cvvController, 
                    TextInputType.number, 
                    true, 
                    formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)]
                  )
                ),
              ],
            ),
            const SizedBox(height: 40),
            
            ElevatedButton(
              onPressed: _isSaving ? null : _saveCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Card', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType type, bool isPassword, {List<TextInputFormatter>? formatters}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword,
      inputFormatters: formatters,
      onChanged: (val) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}
class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll('/', '');
    if (newText.length > 4) newText = newText.substring(0, 4);

    String formatted = '';
    for (int i = 0; i < newText.length; i++) {
      formatted += newText[i];
      if (i == 1 && newText.length > 2) formatted += '/';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
