import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/url_launcher.dart';
// ✅ contains EffectiveGateAdBanner

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({super.key});

  @override
  State<TermsAndConditions> createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
  late String viewType;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    _generateNewViewType();

    refreshTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      setState(() {
        _generateNewViewType();
      });
    });
  }

  void _generateNewViewType() {
    viewType = 'effectivegate-ad-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Terms and Conditions',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                '''📜 Terms and Conditions for Video Upload, Playback, and Sharing

By using our platform to upload, play, and share video content, you agree to the following terms:

1. 📤 Upload and Usage
Users may upload video content for personal use, playback, and sharing with family and friends.
Uploaded content must comply with applicable laws and must not contain harmful, illegal, or copyrighted material without permission.

2. ⏳ Data Retention and Deletion
All uploaded video data will be retained for a maximum of 7 to 30 days.
We reserve the right to delete any content at any time, including within 24 hours, without prior notice.
Users are responsible for backing up their content. We do not guarantee data availability beyond the retention period.

3. 💳 Payments and Refunds
Any payments made for platform services are non-refundable.
We do not offer refunds for accidental purchases, unused services, or dissatisfaction.
All transactions are final.

4. ❌ No Guarantees or Liability
We do not guarantee uninterrupted access, data preservation, or successful playback.
We are not liable for any loss of data, including accidental deletion, corruption, or service outages.
Use of the platform is at your own risk.

5. 🕒 Service Availability
Our platform operates 24/7, but we do not guarantee uptime or availability at all times.
Maintenance, updates, or technical issues may cause temporary disruptions.

6. 👮 Enforcement and Updates
Violation of these terms may result in suspension or termination of access.
We reserve the right to update these terms at any time. Continued use of the platform implies acceptance of any changes.

Sponsored Content Disclosure Our website may contain sponsored advertisements, affiliate links, or promotional content. 
These ads help support the platform and may redirect users to third-party services. We do not guarantee the accuracy or safety of external content and encourage users to exercise discretion when interacting with sponsored material.

📩 Support Contact If you need help, have questions, or want to report an issue, please contact our support team at: ard43440@gmail.com

We aim to respond within 24–48 hours. Your feedback helps us improve
Disclaimer We update our website frequently to improve performance, add new capabilities, and enhance user experience. As a result, some features may be temporarily unavailable, behave unexpectedly, or be removed without notice.
We do not guarantee the availability, accuracy, or functionality of any specific feature or service at any given time. 
By using our platform, you acknowledge that we are not responsible for any issues arising from missing, non-working, or changing features.

⚠️ Sponsored Content Disclosure
This website uses sponsored links and third-party advertisements to support its services. Some of these links may detect user interactions, such as clicks or taps, and redirect you to external websites.
These third-party sites may have their own terms and conditions, privacy policies, and content standards.
By engaging with sponsored content, you acknowledge that you may be redirected to external platforms not controlled by entertainmentcom.in..
We encourage you to review the terms and privacy policies of any third-party site you visit.

User-Shared Data
Any data, content, or personal information that you choose to share publicly on entertainmentcom.in — including in comments, uploads, or interactions — is your sole responsibility.
We do not monitor or control such content and are not liable for any consequences arising from its publication or use by others.
By sharing data publicly, you acknowledge that it may be visible to other users or third parties, and you accept full responsibility for its impact.

* if you reach 1 dollar of upload threshold we have right to send you invoice and personal calls to pay for that, so we can maintain your account.
''',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              const Text(
                'Sponsored Ad refresh Every Second',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              EffectiveGateAdBanner(
                viewType: viewType,
              ), // ✅ Refreshes every 60s
            ],
          ),
        ),
      ),
    );
  }
}
