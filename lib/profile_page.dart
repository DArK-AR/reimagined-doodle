import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/main.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<String> smartLinks = [
    'https://www.effectivegatecpm.com/u9g64jikd2?key=06a2c0cc36ae6d6c9ed4c147c87fe89f',
    'https://www.effectivegatecpm.com/zr4im36d?key=54de008c56d28a4fd55fa3870cb95049',
    'https://www.effectivegatecpm.com/gty6uezmh?key=55c3865afb2543c1d00010d8ff306485',
    'https://www.effectivegatecpm.com/sapqvamfc?key=40e7ccfaa73a1db13a32e43f9ab216b0',
    'https://www.effectivegatecpm.com/sapqvamfc?key=40e7ccfaa73a1db13a32e43f9ab216b0',
    'https://www.effectivegatecpm.com/x8j7nudp?key=4b6ade50c1cc75bdb7fcd20822d14e64',
  ];

  DateTime? lastRedirectTime;

  void _handleSmartLinkTap() {
    final now = DateTime.now();
    if (lastRedirectTime == null ||
        now.difference(lastRedirectTime!).inSeconds >= 60) {
      lastRedirectTime = now;
      final randomLink = smartLinks[Random().nextInt(smartLinks.length)];
      launchUrl(Uri.parse(randomLink), mode: LaunchMode.externalApplication);
    } else {
      final remaining = 60 - now.difference(lastRedirectTime!).inSeconds;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please wait $remaining seconds before next redirect'),
        ),
      );
    }
  }

  String referralCode = '';
  int invitedCount = 0;
  int reward = 0;
  int remainder = 0;
  bool isLoading = true;

  final supportLink = 'https://www.youtube.com/@TimeGames_Time';

  @override
  void initState() {
    super.initState();
    fetchReferralStats();
  }

  Future<void> fetchReferralStats() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('referrals')
          .doc(widget.uid)
          .get();

      final data = doc.data();
      final invitedUsers = List<String>.from(doc.data()?['invitedUsers'] ?? []);
      invitedCount = invitedUsers.length;
      referralCode = data?['code'] ?? '';

      reward = invitedCount ~/ 1000; // $1 per 1000 signups
      remainder = invitedCount % 1000;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _signOutUser() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignUpPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'User';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('User Profile'),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleSmartLinkTap,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome, $displayName',
                        style: const TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      SelectableText(
                        referralCode,
                        style: TextStyle(fontSize: 20, color: Colors.blue),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your Referral Code: \$$referralCode',
                        style: TextStyle(fontSize: 20, color: Colors.blue),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.black,
                        ),

                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: referralCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Refferral code copied')),
                          );
                        },
                        icon: Icon(Icons.copy),
                        label: Text('Copy Referral Code'),
                      ),
                      const SizedBox(height: 20),
                      SelectableText(
                        'Support link:\n$supportLink',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: supportLink));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Link copied to clipboard'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text(
                          'Subscribe and publish your content to earn money on our platform',
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Referral Stats',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('Invited Users: $invitedCount'),
                      Text('Reward Earned: \$$reward'),
                      Text('Next Reward in: ${1000 - remainder} signups'),
                      const SizedBox(height: 20),
                      LinearProgressIndicator(
                        value: remainder / 1000,
                        minHeight: 10,
                        backgroundColor: Colors.grey[300],
                        color: Colors.green,
                      ),
                      const SizedBox(height: 5),
                      Text('$remainder/1000 toward next \$1'),
                      SizedBox(height: 30),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _signOutUser,
                        icon: Icon(Icons.logout),
                        label: Text('Sign Out'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
