import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth_service.dart';
import 'success_screen.dart';



class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureRePassword = true;
  bool _isLoading = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top Right Grey Circle
          Positioned(
            top: -50,
            right: -50,
            child: Hero(
              tag: 'circle1', // Keeps the circle anchored during transition
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          
          // Bottom Left Grey Circle
          Positioned(
            bottom: -50,
            left: -50,
            child: Hero(
              tag: 'circle2', // Keeps the circle anchored during transition
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // ... The rest of your SafeArea and Registration form stays exactly the same
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back Button & Logo Row
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Image.asset('assets/images/logo.png', height: 40),
                      const Spacer(),
                      const SizedBox(width: 48), // Balances the back button
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Create An Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Fields
                  _buildTextField('Name', 'Your Name', _nameController),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    'Birthday', 
                    'MM/DD/YYYY', 
                    _birthdayController,
                    suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField('Email Address', 'Enter Your Email Address', _emailController),
                  const SizedBox(height: 16),
                  
                  _buildPasswordField('Password', _passwordController, _obscurePassword, () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  }),
                  const SizedBox(height: 16),
                  
                  _buildPasswordField('Re Enter The Password', _rePasswordController, _obscureRePassword, () {
                    setState(() => _obscureRePassword = !_obscureRePassword);
                  }),
                  const SizedBox(height: 32),

                  // Next Button
                  ElevatedButton(
                    onPressed: () async {
                      // Basic validation
                      if (_passwordController.text != _rePasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Passwords do not match!')),
                        );
                        return;
                      }

                      setState(() {
                        _isLoading = true; // Start loading spinner
                      });

                      // Call our Auth Service
                      String? result = await AuthService().signUpUser(
                        name: _nameController.text,
                        email: _emailController.text,
                        password: _passwordController.text,
                      );

                      setState(() {
                        _isLoading = false; // Stop loading spinner
                      });

                      if (result == 'success') {
                        // Registration worked! Navigate to the Success Screen!
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SuccessScreen(),
                          ),
                        );
                      } else {
                        // Show the error message from Firebase
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result ?? 'An error occurred')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Or sign in with',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Social Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialIcon(const FaIcon(FontAwesomeIcons.apple, color: Colors.black, size: 28)),
                      const SizedBox(width: 24),
                      _buildSocialIcon(const FaIcon(FontAwesomeIcons.google, color: Colors.red, size: 28)),
                      const SizedBox(width: 24),
                      _buildSocialIcon(const FaIcon(FontAwesomeIcons.facebook, color: Colors.blue, size: 28)),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for standard text fields
  Widget _buildTextField(String label, String hint, TextEditingController controller, {Widget? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  // Helper method specifically for password fields
  Widget _buildPasswordField(String label, TextEditingController controller, bool isObscure, VoidCallback toggleVisibility) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          decoration: InputDecoration(
            hintText: 'Enter Password',
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: toggleVisibility,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcon(Widget iconWidget) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: iconWidget,
    );
  }
}
