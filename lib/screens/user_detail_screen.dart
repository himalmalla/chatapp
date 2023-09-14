import 'package:chatapp/constants/sizes.dart';
import 'package:chatapp/providers/room_provider.dart';
import 'package:chatapp/service/crud_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:get/get.dart';

import 'chat_screen.dart';

class UserDetail extends ConsumerWidget {
  final types.User user;
  UserDetail(this.user);

  @override
  Widget build(BuildContext context, ref) {
    final posts = ref.watch(postsStream);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(user.imageUrl!),
                  ),
                  gapW12,
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.firstName!,
                        style: TextStyle(fontSize: 19),
                      ),
                      Text(user.metadata!['email']),
                      ElevatedButton(
                          onPressed: () async {
                            final response =
                                await ref.read(roomProvider).createRoom(user);
                            if (response != null) {
                              Get.to(() => ChatPage(response));
                            }
                          },
                          child: Text('Message'))
                    ],
                  ))
                ],
              ),
              gapH20,
              Expanded(
                  child: posts.maybeWhen(
                      orElse: () => Container(),
                      data: (data) {
                        final userPost = data
                            .where((element) => element.userId == user.id)
                            .toList();
                        return GridView.builder(
                          itemCount: userPost.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 3 / 2,
                          ),
                          itemBuilder: (context, index) {
                            return Image.network(userPost[index].imageUrl);
                          },
                        );
                      }))
            ],
          ),
        ),
      ),
    );
  }
}
