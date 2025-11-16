// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/auth.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/home_page.dart';

// Background handler must be top-level

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UnicornTect',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
      ),
      home: user != null ? UserHome(user: user) : const SignUpPage(),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController referralController = TextEditingController();

  Future<void> syncToken(String userId) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('user_tokens')
          .doc(userId)
          .set({'token': token}, SetOptions(merge: true));
      debugPrint('Synced FMC token for $userId');
    } else {
      debugPrint('Token is null. Permission may be denied.');
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final userCredential = await signInWithGoogle();
      final user = userCredential.user!;
      final email = user.email ?? 'No email';
      final newUserId = user.uid;
      final enteredCode = referralController.text.trim();

      await FirebaseMessaging.instance.requestPermission();
      await syncToken(newUserId);

      if (enteredCode.isNotEmpty) {
        final refQuery = await FirebaseFirestore.instance
            .collection('referrals')
            .where('code', isEqualTo: enteredCode)
            .limit(1)
            .get();

        if (refQuery.docs.isNotEmpty) {
          final referrerId = refQuery.docs.first.id;
          await FirebaseFirestore.instance
              .collection('referrals')
              .doc(referrerId)
              .update({
                'invitedUsers': FieldValue.arrayUnion([newUserId]),
              });
        }
      }

      final referralCode = newUserId.substring(0, 6);
      await FirebaseFirestore.instance
          .collection('referrals')
          .doc(newUserId)
          .set({'code': referralCode, 'invitedUsers': [], 'reward': 0});

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Signed in as: $email')));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserHome(user: userCredential.user!),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign-in error: $e')));
    }
  }

  @override
  void dispose() {
    referralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Powered by UnicornTech.'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: referralController,
              decoration: const InputDecoration(
                labelText: 'Referral Code (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              onPressed: _signInWithGoogle,
              child: const Text(
                'Sign in with Google',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'By using our service you agree to our Terms and Conditions.',
              style: TextStyle(fontSize: 14, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            const Text(
              'This site may contain 18+ video. If you are under 18, please exit.',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
