import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  DateTime? lastRedirectTime;

  final List<String> smartLinks = [
    'https://www.effectivegatecpm.com/sapqvamfc?key=40e7ccfaa73a1db13a32e43f9ab216b0',
    'https://www.effectivegatecpm.com/x8j7nudp?key=4b6ade50c1cc75bdb7fcd20822d14e64',
    'https://www.effectivegatecpm.com/teejd82v?key=be714df20ddfcc2b9a8dbda5cd386497',
    'https://www.effectivegatecpm.com/j5esacgw6?key=1a031aa1f073f1fb94748e94585c2617',
    'https://www.effectivegatecpm.com/v7xtykx70?key=85f4cd6b27a003cce406bbafb60c7b89',
  ];

  Future<Map<String, dynamic>> fetchUserStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {'videoCount': 0, 'earnings': 0.0, 'progress': 0};

    final snapshot = await FirebaseFirestore.instance
        .collection('videos')
        .where('userId', isEqualTo: user.uid)
        .get();

    final videoCount = snapshot.size;
    final earnings = (videoCount ~/ 10).toDouble(); // $1 per 10 videos
    final progress = videoCount % 10;

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    await userRef.set({
      'userId': user.uid,
      'displayName': user.uid,
      'uploadCount': videoCount,
      'walletBalance': earnings,
    }, SetOptions(merge: true));

    return {
      'videoCount': videoCount,
      'earnings': earnings,
      'progress': progress,
    };
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue, title: const Text('Wallet')),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleSmartLinkTap,
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchUserStats(),
          builder: (context, snapshot) {
            final videoCount = snapshot.data?['videoCount'] ?? 0;
            final earnings = snapshot.data?['earnings'] ?? 0.0;
            final progress = snapshot.data?['progress'] ?? 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      '📹 Videos uploaded: $videoCount',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '💰 Earnings: \$${earnings.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '⏳ ${10 - progress} more video${(10 - progress) == 1 ? '' : 's'} to reach next \$1',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: progress / 10,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.green,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '⚠️ You need at least \$20 in your wallet to withdraw money.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    Image.network(
                      'https://res.cloudinary.com/dn08na1dg/image/upload/v1761811597/photo_2025-10-27_22-07-39_yqlwpk.jpg',
                    ),
                    SizedBox(height: 8),
                    Text(
                      'we pay you through upi and banktransfer with compliance with Our Privacy and Policy',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'WhatsApp your earning Once you reach 20 dollars 7906408246',
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
