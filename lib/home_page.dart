// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/notification.dart';
import 'package:flutter_application_1/profile_page.dart';
import 'package:flutter_application_1/shop.dart';
import 'package:flutter_application_1/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_application_1/upload.dart';
import 'package:flutter_application_1/wallet.dart';
import 'package:visibility_detector/visibility_detector.dart';

class UserHome extends StatefulWidget {
  final User user;

  const UserHome({super.key, required this.user});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  List<String> videoUrls = [];
  bool isLoading = true;
  bool isFetchingMore = false;
  DocumentSnapshot? lastDocument;
  late String viewType;
  final int pageSize = 10;

  @override
  void initState() {
    super.initState();
    viewType = 'effectivegate-ad-${DateTime.now().millisecondsSinceEpoch}';
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    final query = FirebaseFirestore.instance
        .collection('videos')
        .orderBy('uploadedAt', descending: true)
        .limit(pageSize);

    final snapshot = lastDocument != null
        ? await query.startAfterDocument(lastDocument!).get()
        : await query.get();

    final urls = snapshot.docs
        .map((doc) => doc['videoUrl'] as String)
        .where((url) => url.isNotEmpty)
        .toList();

    setState(() {
      videoUrls.addAll(urls);
      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }
      isLoading = false;
      isFetchingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.user.displayName ?? 'User';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      uid: FirebaseAuth.instance.currentUser!.uid,
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.black),
              ),
            ),
          ],
        ),
        actions: [
          Tooltip(
            message: 'Notifcations',
            child: TextButton.icon(
              icon: Icon(Icons.notifications, color: Colors.white),
              label: SizedBox.shrink(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationPage()),
                );
              },
            ),
          ),
          Tooltip(
            message: "Upload",
            child: TextButton.icon(
              icon: const Icon(Icons.upload_file, color: Colors.white),
              label: SizedBox.shrink(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VideoUploadAndPlayPage(user: widget.user),
                  ),
                );
              },
            ),
          ),
          Tooltip(
            message: "Wallet",
            child: TextButton.icon(
              icon: const Icon(Icons.wallet, color: Colors.white),
              label: SizedBox.shrink(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WalletPage()),
                );
              },
            ),
          ),
          Tooltip(
            message: "Sponsored Ads",
            child: TextButton.icon(
              icon: Icon(Icons.shop, color: Colors.white),
              label: SizedBox.shrink(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScrollableImagePage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: videoUrls.length + (videoUrls.length ~/ 3),
              itemBuilder: (context, index) {
                final adInterval = 3;
                final isAdIndex = (index + 1) % (adInterval + 1) == 0;

                if (isAdIndex) {
                  return EffectiveGateAdBanner(viewType: viewType);
                }
                final videoIndex = index - (index ~/ (adInterval + 1));
                return GestureDetector(
                  child: Stack(
                    children: [
                      VideoPlayerWidget(videoUrl: videoUrls[videoIndex]),
                      Positioned(
                        top: 20,
                        left: 10,
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person, color: Colors.black),
                            ),

                            const SizedBox(width: 12),
                            Text(
                              displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool isVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = VideoPlayerController.network(widget.videoUrl)
      ..setLooping(true)
      ..initialize().then((_) {
        if (mounted) setState(() {});
        if (isVisible) _controller.play();
      });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _controller.pause();
    } else if (state == AppLifecycleState.resumed && isVisible) {
      _controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.videoUrl),
      onVisibilityChanged: (info) {
        isVisible = info.visibleFraction > 0;
        if (!isVisible && _controller.value.isPlaying) {
          _controller.pause();
        } else if (isVisible && !_controller.value.isPlaying) {
          _controller.play();
        }
      },
      child: _controller.value.isInitialized
          ? SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
