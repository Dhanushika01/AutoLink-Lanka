import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Sign Up Method ---
  Future<String?> signUpUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Create the user in Firebase Authentication
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Save their extra data to Firestore matching your schema
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'email': email,
        'name': name, // Storing name even though it's not strictly in the diagram, it's in your UI!
        'role': 'customer', // Defaulting to customer role
      });

      return 'success'; // Return success if everything worked
    } on FirebaseAuthException catch (e) {
      return e.message; // Return the exact Firebase error (e.g., "Email already in use")
    } catch (e) {
      return e.toString(); // Catch any other errors
    }
  }

  // --- Log In Method ---
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return 'success';
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}
