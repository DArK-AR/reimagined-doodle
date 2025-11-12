import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SmartLinkPage extends StatefulWidget {
  const SmartLinkPage({super.key});

  @override
  State<SmartLinkPage> createState() => _SmartLinkPageState();
}

class _SmartLinkPageState extends State<SmartLinkPage> {
  final List<String> smartLinks = [
    'https://www.effectivegatecpm.com/j5esacgw6?key=1a031aa1f073f1fb94748e94585c2617',
    'https://www.effectivegatecpm.com/v7xtykx70?key=85f4cd6b27a003cce406bbafb60c7b89',
    'https://www.effectivegatecpm.com/dkzmy2im?key=3ad656958dd09c6574476ac30208eb31',
    'https://www.effectivegatecpm.com/cw3rd7yzu?key=629f0c64e5a5179f18e8f59e76561121',
    'https://www.effectivegatecpm.com/uu89zn9m?key=5ade00c45fcf9c57d1a3d57dca2efb91',
    'https://www.effectivegatecpm.com/brx5gq68?key=e912d0dbc4848ccda47088e421f56353',
    // 🔁 Add more links here
  ];

  int currentIndex = 0;

  Future<void> _launchNextLink() async {
    final Uri uri = Uri.parse(smartLinks[currentIndex]);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    setState(() {
      currentIndex = (currentIndex + 1) % smartLinks.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchNextLink,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Smartlink Viewer'),
          backgroundColor: Colors.blue,
        ),
        body: const Center(
          child: Text(
            """🔒 Privacy Policy for Video Upload and Sharing

Effective Date: [31/10/2025]

We value your privacy and are committed to protecting your personal data. This Privacy Policy explains how we handle video uploads, playback, and sharing features on our platform.

1. 📹 Video Upload and Sharing
Users may upload videos for personal use and share them with family, friends and public.
Uploaded videos are stored securely and are only accessible to the user and those they choose to share with.
We do not publicly display or distribute user content without explicit permission.

2. ⏳ Data Retention
Uploaded videos are retained for a limited period, typically between 7 to 30 days.
We may delete content at any time, including within 24 hours, based on system policies or user activity.
Users are responsible for sharing, downloading or backing up their content before it is deleted.

3. 🔐 Data Security
We implement reasonable security measures to protect your videos from unauthorized access, alteration, or deletion.
However, no system is 100% secure. We cannot guarantee absolute protection against data loss or breaches.

4. 👥 Sharing Controls
Users control who can view their videos or where to share by sharing links or access permissions.
We do not monitor or moderate shared content unless required by law or reported for abuse.

5. 💳 Payment and Refunds
Payments made for platform services are non-refundable.
We do not offer compensation for lost data, accidental deletion, or service interruptions.

6. 📈 Usage Analytics
We may collect anonymized usage data to improve platform performance and user experience.
This data does not include personal video content or identifiable information.

7. ⚖️ Legal Compliance
We comply with applicable data protection laws and cooperate with legal authorities when required.
Users must not upload content that violates laws or infringes on others' rights.

8. 🔄 Policy Updates
We may update this Privacy Policy from time to time. Continued use of the platform implies acceptance of any changes.
Users will be notified of significant updates via the platform or email.

9. 🚫 Third-Party Access and Confidentiality
We do not share, sell, or disclose your uploaded videos or personal data to any third party without your explicit permission.
No external party is permitted to view, access, or use your confidential content, including documents, videos, or metadata, unless required by law or authorized by you.
We maintain strict access controls to ensure your data remains private and secure.

10. 💰 We pay users for uploading content only to our choosen sponsor content Creators not to all creator updated data for monitor and analysis.""",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
