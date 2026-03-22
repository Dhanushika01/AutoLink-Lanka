import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

final ValueNotifier<String> globalLocation = ValueNotifier<String>('Colombo');
final ValueNotifier<int> globalTabIndex = ValueNotifier<int>(0);
final ValueNotifier<String?> globalProfileImagePath = ValueNotifier<String?>(null);

Future<void> loadGlobalProfileImage() async {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId != null) {
    final prefs = await SharedPreferences.getInstance();
    globalProfileImagePath.value = prefs.getString('profile_pic_$userId');
  }
}
