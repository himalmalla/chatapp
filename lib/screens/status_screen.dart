import 'package:chatapp/providers/auth_provider.dart';
import 'package:chatapp/screens/auth_screen.dart';
import 'package:chatapp/screens/homepage_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (context, ref, child) {
          final authData = ref.watch(userStream);
          return authData.when(
              data: (data) {
                if (data == null) {
                  return Authpage();
                } else {
                  return HomePage();
                }
              },
              error: (err, stack) => Center(child: Text('$err')),
              loading: () => const Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }
}
