import 'package:chatapp/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../providers/room_provider.dart';

class Recentchats extends ConsumerWidget {
  const Recentchats({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final roomData = ref.watch(rooms);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: roomData.when(
              data: (data) {
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        onTap: () {
                          Get.to(() => ChatPage(data[index]));
                        },
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(data[index].imageUrl!),
                        ),
                        title: Text(data[index].name!),
                      ),
                    );
                  },
                );
              },
              error: (err, stack) => Text('$err'),
              loading: () => const Center(child: CircularProgressIndicator())),
        ));
  }
}
