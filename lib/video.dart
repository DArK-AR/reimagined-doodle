import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  final String videoId;
  const VideoPage({super.key, required this.videoId});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  Map<String, dynamic>? videoData;
  VideoPlayerController? _controller;
  bool _isLoading = true;
  late String viewType;
  Timer? refreshTimer;

  bool _isMuted = true; // 🔑 track mute state

  @override
  void initState() {
    super.initState();
    fetchVideo();
    _generateNewViewType();
    refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) {
        setState(() {
          _generateNewViewType();
        });
      }
    });
  }

  void _generateNewViewType() {
    viewType = 'effectivegate-ad-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> fetchVideo() async {
    final doc = await FirebaseFirestore.instance
        .collection('videos')
        .doc(widget.videoId)
        .get();

    if (doc.exists) {
      videoData = doc.data();
      if (videoData?['videoUrl'] != null) {
        _initializeVideo(videoData!['videoUrl']);
      } else {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _initializeVideo(String url) async {
    _controller?.dispose();
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..setLooping(true)
      ..setVolume(0); // start muted

    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _isLoading = false);
      _controller!.play();
    } catch (e) {
      debugPrint("Video initialization failed: $e");
    }
  }

  void _toggleMute() {
    if (_controller == null) return;
    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0 : 1.0);
    });
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _launchPromoLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch promo link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoId = widget.videoId;
    final shareUrl = "https://entertainmentcom.site/#/videos/$videoId";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(videoData?['title'] ?? 'Video'),
        actions: [
          if (_controller != null && _controller!.value.isInitialized)
            IconButton(
              icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
              onPressed: _toggleMute,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_controller != null && _controller!.value.isInitialized)
                      AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            VideoPlayer(_controller!),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: Icon(
                                  _isMuted ? Icons.volume_off : Icons.volume_up,
                                  color: Colors.white,
                                ),
                                onPressed: _toggleMute,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const Center(
                        child: Text(
                          "IF VIDEO IS NOT LOADED YET, CLICK TO GO HOME",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // ✅ Promo button
                    if (videoData?['promoLink'] != null &&
                        (videoData?['promoLink'] as String).isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () =>
                              _launchPromoLink(videoData!['promoLink']),
                          child: Text(
                            videoData?['promoType'] ?? 'Open Promo',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 10),

                    // ✅ Share button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.share),
                        label: const Text("Share Video"),
                        onPressed: () {
                          SharePlus.instance.share(
                            ShareParams(uri: Uri.parse(shareUrl)),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ✅ Copy Link button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.copy),
                        label: const Text("Copy Link"),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: shareUrl));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Link copied to clipboard"),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ✅ Home Page button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.home),
                        label: const Text("Go to Home"),
                        onPressed: () {
                          context.go('/');
                        },
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "IF VIDEO NOT LOAD, CLICK ON GO HOME BUTTON",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 40),
                    const Text(
                      'Sponsored Ad (refreshes every 60 seconds)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 100,
                      alignment: Alignment.center,
                      child: EffectiveGateAdBanner(viewType: viewType),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
