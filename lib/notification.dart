// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter, use_build_context_synchronously
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final List<RemoteMessage> _messages = [];

  @override
  void initState() {
    super.initState();

    // Example usage of _messaging
    _messaging.getToken().then((token) {
      debugPrint("FMC Token in Page: $token");
    });

    _messaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Foreground message in page: ${message.notification?.title}");
      setState(() {
        _messages.add(message);

        if (_messages.length > 10) {
          _messages.removeAt(0);
        }
      });
    });

    html.window.onMessage.listen((event) {
      final data = event.data;
      if (data is Map && data['videoUrl'] != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPage(videoUrl: data['videoUrl']),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Notifications"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('videos')
            .orderBy('uploadedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notification yet"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? "🎥 New Video Uploaded";
              final body = data['uploadedAt'] != null
                  ? "${data['uploadedBy']} just uploaded a new  video."
                  : "Watch trending videos now";
              final videoUrl = data['videoUrl'];

              return Hero(
                tag: 'ListTile-Hero-$index',
                child: Material(
                  child: Column(
                    children: [
                      ListTile(
                        tileColor: Colors.white,
                        leading: Icon(Icons.notifications, color: Colors.red),
                        title: Text(
                          title,
                          style: TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(
                          body,
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () {
                          if (videoUrl != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VideoPage(videoUrl: videoUrl),
                              ),
                            );
                          }
                        },
                      ),
                      Divider(color: Colors.black, thickness: 1, height: 0),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class VideoPage extends StatefulWidget {
  final String videoUrl;
  const VideoPage({super.key, required this.videoUrl});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _initialized = true;
          });
          _controller.play();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Player")),
      body: Center(
        child: _initialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
