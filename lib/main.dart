// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/auth.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/home_page.dart';
import 'package:url_launcher/url_launcher.dart';

// Backround handler must be top-level


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  runApp(MyApp());
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
      home: user != null ? UserHome(user: user) : SignUpPage(),
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

  final List<String> smartLinks = [
    'https://www.effectivegatecpm.com/n1u739xe?key=1152b0a95c6f6011f782ad822526c06d',
    'https://www.effectivegatecpm.com/phz9jfs3m?key=ea6c354ebd158757f4a4a718ca9bf801',
    'https://www.effectivegatecpm.com/aid79xw6c?key=ee804a1c0b4abbd53fba6da50422d054',
    'https://www.effectivegatecpm.com/qumcb8cg1g?key=c2d55d03a9f53f81554fc73ae69b07db',
    'https://www.effectivegatecpm.com/u9g64jikd2?key=06a2c0cc36ae6d6c9ed4c147c87fe89f',
  ];
  int currentLinkIndex = 0;
  bool canOpenLink = true;

  Future<void> _openSmartLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
    }
  }

  void _handleSmartLinkTap() async {
    if (!canOpenLink || currentLinkIndex >= smartLinks.length) return;

    final url = smartLinks[currentLinkIndex];
    currentLinkIndex++;
    canOpenLink = false;

    await _openSmartLink(url);

    Future.delayed(Duration(seconds: 60), () {
      setState(() {
        canOpenLink = true;
      });
    });
  }

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
  void initState() {
    super.initState();

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await syncToken(user.uid);
      }
    });
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
      body: GestureDetector(
        onTap: _handleSmartLinkTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: referralController,
                decoration: InputDecoration(
                  labelText: 'Referral Code (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
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
              SizedBox(height: 80),
              Text(
                'This site contains ads and link. Using our service your are agree to our Terms and Condition, Use our platform to share your data to publicly.',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              SizedBox(height: 5),
              Text(
                'This site may contain 18+ video if you are not under 18+, be in provision zone',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
