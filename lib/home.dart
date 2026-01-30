
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/upload.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<DocumentSnapshot> videoDocs = [];
  bool isLoading = true;
  DocumentSnapshot? lastDocument;
  final int pageSize = 10;

  bool _showSearch = false;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
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
    });
  }

  String generateNameFromEmail(String email) {
    final localPart = email.split('@').first;
    final cleaned = localPart.replaceAll(RegExp(r'[._]'), ' ');
    final words = cleaned
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
    return words.trim();
  }

  Future<void> _launchPromoLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch promo link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final filteredDocs = _searchQuery.isEmpty
        ? videoDocs
        : videoDocs
              .where(
                (doc) => (doc['title'] ?? '').toString().toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: !_showSearch
            ? Text(
                "UnicornTech - ${widget.user.email != null ? generateNameFromEmail(widget.user.email!) : 'User'}",
              )
            : TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: "Search videos...",
                  hintStyle: TextStyle(color: Colors.black),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            tooltip: "Search",
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                _searchQuery = "";
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.upload),
            tooltip: "Upload Video",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoUpload(user: widget.user),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final videoId = doc.id;
            final title = doc['title'] ?? 'Untitled';
            final uploadedBy = doc['uploadedBy'] ?? 'Unknown';
            final promoType = doc['promoType'] ?? 'Promo';
            final promoLink = doc['promoLink'] ?? '';

            return GestureDetector(
              onTap: () {
                context.go('/videos/$videoId');
              },
              child: Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  tileColor: Colors.red,
                  title: Text(
                    title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "By $uploadedBy",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_arrow, color: Colors.white),
                      if (promoLink.isNotEmpty)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _launchPromoLink(promoLink),
                          child: Text(
                            promoType,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}