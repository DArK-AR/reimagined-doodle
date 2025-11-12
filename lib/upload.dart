// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/privacy_policy.dart';
import 'package:flutter_application_1/terms_and_condition.dart';
import 'package:flutter_application_1/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class VideoUploadAndPlayPage extends StatefulWidget {
  final User user;

  const VideoUploadAndPlayPage({super.key, required this.user});

  @override
  State<VideoUploadAndPlayPage> createState() => _VideoUploadAndPlayPageState();
}

class _VideoUploadAndPlayPageState extends State<VideoUploadAndPlayPage> {
  String? videoUrl;
  double? _uploadProgress;
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  late String viewType;
  Timer? refreshTimer;

  final List<String> adLinks = [
    'https://www.effectivegatecpm.com/n1u739xe?key=1152b0a95c6f6011f782ad822526c06d',
    'https://www.effectivegatecpm.com/phz9jfs3m?key=ea6c354ebd158757f4a4a718ca9bf801',
    'https://www.effectivegatecpm.com/aid79xw6c?key=ee804a1c0b4abbd53fba6da50422d054',
    'https://www.effectivegatecpm.com/qumcb8cg1g?key=c2d55d03a9f53f81554fc73ae69b07db',
    'https://www.effectivegatecpm.com/u9g64jikd2?key=06a2c0cc36ae6d6c9ed4c147c87fe89f',
    'https://www.effectivegatecpm.com/zr4im36d?key=54de008c56d28a4fd55fa3870cb95049',
    'https://www.effectivegatecpm.com/gty6uezmh?key=55c3865afb2543c1d00010d8ff306485',
    'https://www.effectivegatecpm.com/sapqvamfc?key=40e7ccfaa73a1db13a32e43f9ab216b0',
    'https://www.effectivegatecpm.com/x8j7nudp?key=4b6ade50c1cc75bdb7fcd20822d14e64',
    'https://www.effectivegatecpm.com/teejd82v?key=be714df20ddfcc2b9a8dbda5cd386497',
  ];
  int currentAdIndex = 0;

  Future<void> _launchNextAd() async {
    final Uri uri = Uri.parse(adLinks[currentAdIndex]);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    setState(() {
      currentAdIndex = (currentAdIndex + 1) % adLinks.length;
    });
  }

  @override
  void initState() {
    super.initState();
    _generateNewViewType();
    refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
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
    if (_isInitialized) _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> pickAndUploadVideo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // ✅ Check how many videos uploaded today
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('videos')
        .where('userId', isEqualTo: user.uid)
        .where(
          'uploadedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('uploadedAt', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    if (snapshot.size >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only upload 5 videos per day.')),
      );
      return;
    }

    // ✅ Proceed with upload
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

        await FirebaseFirestore.instance.collection('videos').add({
          'videoUrl': downloadUrl,
          'uploadedAt': Timestamp.now(),
          'userId': user.uid,
          'uploadedBy': user.displayName ?? 'Someone',
          'title': 'Uploaded A new Video',
          'discription': 'new videos are coming soon',
        });

        setState(() {
          videoUrl = downloadUrl;
          _uploadProgress = null;
        });

        initializeVideo(downloadUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video uploaded successfully!')),
        );
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No video selected')));
    }
  }

  void initializeVideo(String url) {
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize()
          .then((_) {
            if (mounted) {
              setState(() {
                _isInitialized = true;
              });
              _controller.play();
            }
          })
          .catchError((error) {
            if (mounted) {
              setState(() {
                _errorMessage = 'Failed to load video: $error';
              });
            }
          });
  }

  void playFromSearch() {
    final link = _searchController.text.trim();
    if (Uri.tryParse(link)?.hasAbsolutePath ?? false) {
      initializeVideo(link);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid video link')));
    }
  }

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse("https://share.google/bIQ59BaMFFp66wJzX");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchNextAd,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Upload & Play Video'),
          backgroundColor: Colors.blue,
        ),
        body: GestureDetector(
          onTap: _launchNextAd,
          behavior: HitTestBehavior.translucent,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: pickAndUploadVideo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(8),
                      ),
                    ),
                    child: Text('Select & Upload Video'),
                  ),
                  if (_uploadProgress != null) ...[
                    SizedBox(height: 20),
                    Text(
                      'Uploading: ${(_uploadProgress! * 100).toStringAsFixed(0)}%',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    LinearProgressIndicator(value: _uploadProgress),
                  ],
                  SizedBox(height: 10),
                  Image.network(
                    'https://res.cloudinary.com/dn08na1dg/image/upload/v1762957099/content-sharing-strategy_gnkqyq.jpg',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image, size: 100),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return CircularProgressIndicator();
                    },
                  ),
                  ElevatedButton(
                    onPressed: _launchUrl,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(8),
                      ),
                    ),
                    child: Text('Download your own new Trends Here'),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Paste your own this platform Link here:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Enter video URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: playFromSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    icon: Icon(Icons.search),
                    label: Text('Play from Link'),
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_isInitialized)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: GestureDetector(
                        onTap: _launchNextAd,
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: Stack(
                            children: [
                              VideoPlayer(_controller),
                              Positioned.fill(
                                child: GestureDetector(
                                  onTap: _launchNextAd,
                                  behavior: HitTestBehavior.translucent,
                                  child: Container(color: Colors.transparent),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (_isInitialized)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 80, 20, 80),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _controller.value.isPlaying
                                ? _controller.pause()
                                : _controller.play();
                          });
                        },
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        label: Text(
                          _controller.value.isPlaying ? 'Pause' : 'Play',
                        ),
                      ),
                    ),
                  if (videoUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Shareable Link:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          SelectableText(
                            videoUrl!,
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              initializeVideo(videoUrl!);
                            },
                            icon: Icon(Icons.play_circle),
                            label: Text('Play Video Again'),
                          ),
                          SizedBox(height: 5),
                          Image.network(
                            'https://res.cloudinary.com/dn08na1dg/image/upload/v1761811597/photo_2025-10-27_22-07-39_yqlwpk.jpg',
                            height: 400,
                            width: 600,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Container(
                              color: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Text(
                                'Secure your data with privacy, Pay 299 now  to QR Code for service usage and support your account data and make this site more user friendly',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Upload Best video so if your video go viral we pay you 5000 dollar',
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  const SizedBox(height: 40),
                  const Text(
                    'Sponsored Ad (refreshes every second)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 100,

                    alignment: Alignment.center,
                    child: EffectiveGateAdBanner(viewType: viewType),
                  ),

                  const SizedBox(height: 40),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TermsAndConditions(),
                        ),
                      );
                    },
                    child: Text(
                      'View Terms and Conditions',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SmartLinkPage(),
                        ),
                      );
                    },
                    child: Text(
                      'View Privacy and Policy',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
