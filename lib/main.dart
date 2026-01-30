import 'package:flutter/material.dart';
import 'package:flutter_application_1/signin.dart';
import 'package:flutter_application_1/video.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) =>  AuthGate()),
        GoRoute(
          path: '/videos/:id',
          builder: (context, state) {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              return  AuthGate();
            }
            final id = state.pathParameters['id']!;
            return VideoPage(videoId: id);
          },
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'UnicornTech',
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}

