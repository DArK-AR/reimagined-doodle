import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoUpload extends StatefulWidget {
  final User user;
  const VideoUpload({super.key, required this.user});

  @override
  State<VideoUpload> createState() => _VideoUploadState();
}

class _VideoUploadState extends State<VideoUpload> {
  double? _uploadProgress;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _promoLinkController = TextEditingController();
  final TextEditingController _promoTypeController = TextEditingController();

  Future<void> pickAndUploadVideo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // ✅ Get monthly limit from user's Firestore profile (document keyed by UID)
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    int monthlyLimit = 1; // default fallback
    if (userDoc.exists && userDoc.data()!.containsKey('monthlyUploadLimit')) {
      monthlyLimit = userDoc['monthlyUploadLimit'];
    }

    // ✅ Check monthly upload limit
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    final snapshot = await FirebaseFirestore.instance
        .collection('videos')
        .where('userId', isEqualTo: user.uid)
        .where(
          'uploadedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
        )
        .where('uploadedAt', isLessThan: Timestamp.fromDate(endOfMonth))
        .get();

    if (snapshot.size >= monthlyLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You can only upload $monthlyLimit video per month.'),
        ),
      );
      return;
    }

    // ✅ Pick video
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.first.bytes != null) {
      Uint8List fileBytes = result.files.first.bytes!;
      String fileName = result.files.first.name;

      final storageRef = FirebaseStorage.instance.ref('videos/$fileName');
      final metadata = SettableMetadata(contentType: 'video/mp4');
      final uploadTask = storageRef.putData(fileBytes, metadata);

      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        setState(() {
          _uploadProgress = progress;
        });
      });

      await uploadTask.whenComplete(() async {
        final downloadUrl = await storageRef.getDownloadURL();

        // ✅ Save video + fields to Firestore
        await FirebaseFirestore.instance.collection('videos').add({
          'videoUrl': downloadUrl,
          'uploadedAt': Timestamp.now(),
          'userId': user.uid,
          'uploadedBy': user.displayName ?? 'Someone',
          'title': _titleController.text.trim(),
          'promoLink': _promoLinkController.text.trim(),
          'promoType': _promoTypeController.text.trim(),
          'like': 0,
          'view': 0,
        });

        setState(() {
          _uploadProgress = null;

          // ✅ Clear text fields after save
          _titleController.clear();
          _promoLinkController.clear();
          _promoTypeController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video uploaded successfully!')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No video selected')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Upload Video'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Video Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _promoTypeController,
              decoration: const InputDecoration(
                labelText: 'Promo Type (e.g. YouTube, Instagram)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _promoLinkController,
              decoration: const InputDecoration(
                labelText: 'Promo Link',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: pickAndUploadVideo,
              child: const Text('Select & Upload Video'),
            ),
            if (_uploadProgress != null) ...[
              const SizedBox(height: 20),
              Text(
                'Uploading: ${(_uploadProgress! * 100).toStringAsFixed(0)}%',
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(value: _uploadProgress),
            ],
            const SizedBox(height: 20),
            Text(
              "PAY 20 FOR 1 NEW AD!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Image.network(
              "https://res.cloudinary.com/dn08na1dg/image/upload/v1761811597/photo_2025-10-27_22-07-39_yqlwpk.jpg",
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.contact_page),
                label: const Text(
                  "Once payment done Contact Us",
                  textAlign: TextAlign.center,
                ),
                onPressed: () async {
                  const phoneNumber = "7906408246"; // include country code
                  final uri = Uri.parse("https://wa.me/$phoneNumber");

                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Could not launch WhatsApp"),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
