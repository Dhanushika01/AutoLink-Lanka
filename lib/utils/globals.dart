import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Global location state
final ValueNotifier<String> globalLocation = ValueNotifier<String>('Colombo');

// Global tab state so the Sidebar can change the bottom navigation!
final ValueNotifier<int> globalTabIndex = ValueNotifier<int>(0);


// Global profile image state!
final ValueNotifier<String?> globalProfileImagePath = ValueNotifier<String?>(null);

// Helper function to load the saved image when the app starts
Future<void> loadGlobalProfileImage() async {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId != null) {
    final prefs = await SharedPreferences.getInstance();
    globalProfileImagePath.value = prefs.getString('profile_pic_$userId');
  }
}
