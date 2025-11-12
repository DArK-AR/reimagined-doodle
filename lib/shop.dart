// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ScrollableImagePage extends StatelessWidget {
  const ScrollableImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Sponsored Ads'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.network(
              'https://res.cloudinary.com/dn08na1dg/image/upload/v1762231861/519hAJzvLqL._SX679__apynuo.jpg',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 100),
            ),
            const SizedBox(height: 20),
            const Text(
              'NOBERO Printed Hoodies for Man',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () async {
                final Uri uri = Uri.parse('https://amzn.to/43LZEUf');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not launch link')),
                  );
                }
              },
              child: const Text('Buy Now Sponsored Ad'),
            ),
            const SizedBox(height: 40),
            Image.network(
              'https://res.cloudinary.com/dn08na1dg/image/upload/v1762230374/51VmIOwoLDL._SX569__vlygbp.jpg',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 100),
            ),
            SizedBox(height: 8),
            Text(
              'ADRO Cotton Men Hooded Sweatshirt',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () async {
                final Uri uri = Uri.parse('https://amzn.to/49zDbgU');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not launch link')),
                  );
                }
              },
              child: const Text('Buy Now sponsor Ad'),
            ),
            SizedBox(height: 20),
            Image.network(
              'https://res.cloudinary.com/dn08na1dg/image/upload/v1762116001/BCO.291567a6-b075-4cbb-81c5-d4935710a1a1_ly37ud.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.broken_image, size: 100),
            ),
            SizedBox(height: 8),
            Text(
              'Add your Ads Here As a sponsor',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () async {
                final Uri uri = Uri.parse(
                  'https://wa.me/message/ZWJH3PR6EUQOL1',
                );
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not launch Link')),
                  );
                }
              },
              child: Text('Add Now Sponsored Ad'),
            ),
            SizedBox(height: 20),
            Image.network(
              'https://res.cloudinary.com/dn08na1dg/image/upload/v1761811597/photo_2025-10-27_22-07-39_yqlwpk.jpg',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 100),
            ),
            SizedBox(height: 20),
            Text(
              'Pay some money for usage and services on this platform Sponsored Ad',
              style: TextStyle(
                color: Colors.white,
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
