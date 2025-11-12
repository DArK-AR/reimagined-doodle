import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential> signInWithGoogle() async {
  GoogleAuthProvider googleProvider = GoogleAuthProvider();

  googleProvider.addScope('email');
  googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

  return await FirebaseAuth.instance.signInWithPopup(googleProvider);
}
