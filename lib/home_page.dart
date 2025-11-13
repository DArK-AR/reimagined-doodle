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
  List<DocumentSnapshot> videoDocs = [];
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

    setState(() {
      videoDocs.addAll(snapshot.docs);
      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }
      isLoading = false;
      isFetchingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.black),
              ),
            ),
          ],
        ),
        actions: [
          Tooltip(
            message: 'Notifications',
            child: TextButton.icon(
              icon: const Icon(Icons.notifications, color: Colors.white),
              label: const SizedBox.shrink(),
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
              label: const SizedBox.shrink(),
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
              label: const SizedBox.shrink(),
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
              icon: const Icon(Icons.shop, color: Colors.white),
              label: const SizedBox.shrink(),
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
              itemCount: videoDocs.length + (videoDocs.length ~/ 3),
              itemBuilder: (context, index) {
                final adInterval = 3;
                final isAdIndex = (index + 1) % (adInterval + 1) == 0;

                if (isAdIndex) {
                  return EffectiveGateAdBanner(viewType: viewType);
                }

                final videoIndex = index - (index ~/ (adInterval + 1));
                final videoData =
                    videoDocs[videoIndex].data() as Map<String, dynamic>;

                return GestureDetector(
                  child: Stack(
                    children: [
                      VideoPlayerWidget(
                        videoUrl: videoData['videoUrl'],
                        videoId: videoDocs[videoIndex].id,
                      ),
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
                              videoData['uploadedBy'] ?? 'Unknown',
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
                      Positioned(
                        right: 20,
                        top: MediaQuery.of(context).size.height / 2 - 60,
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('videos')
                              .doc(videoDocs[videoIndex].id)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox();
                            final data =
                                snapshot.data!.data() as Map<String, dynamic>;
                            final views = data['views'] ?? 0;
                            final likes = data['likes'] ?? 0;

                            return Column(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.thumb_up,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: () async {
                                    final uid =
                                        FirebaseAuth.instance.currentUser!.uid;
                                    final docRef = FirebaseFirestore.instance
                                        .collection('videos')
                                        .doc(videoDocs[videoIndex].id);

                                    final likeDoc = await docRef
                                        .collection('likes')
                                        .doc(uid)
                                        .get();
                                    if (!likeDoc.exists) {
                                      await docRef
                                          .collection('likes')
                                          .doc(uid)
                                          .set({
                                            'likedAt':
                                                FieldValue.serverTimestamp(),
                                          });
                                      await docRef.update({
                                        'likes': FieldValue.increment(1),
                                      });
                                    }
                                  },
                                ),
                                Text(
                                  "Likes: $likes",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 20),
                                const Icon(
                                  Icons.remove_red_eye,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                Text(
                                  "Views: $views",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            );
                          },
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
  final String
  videoId; // 👈 add videoId so we know which Firestore doc to update

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.videoId,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool isVisible = true;

  Future<void> _incrementViews(String videoId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance.collection('videos').doc(videoId);

    final viewDoc = await docRef.collection('views').doc(uid).get();
    if (!viewDoc.exists) {
      await docRef.collection('views').doc(uid).set({
        'viewedAt': FieldValue.serverTimestamp(),
      });
      await docRef.update({'views': FieldValue.increment(1)});
    }
  }

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

          // 👇 call increment without await (fire‑and‑forget)
          _incrementViews(widget.videoId);
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
