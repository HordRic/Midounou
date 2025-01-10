import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:midounou/pages/signup.dart';

import 'bottomnav.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return const BottomNav();
        } else {
          return const SignUp();
        }
      },
    );
  }
}
