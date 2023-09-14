import 'package:chatapp/providers/crud_provider.dart';
import 'package:chatapp/service/crud_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../models/post.dart';

class DetailPage extends StatelessWidget {
  final Post post;
  final types.User user;
  DetailPage(this.post, this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer(builder: (context, ref, child) {
            final posts = ref.watch(postsStream);
            return Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(hintText: 'add comment'),
                  onFieldSubmitted: (val) {
                    if (val.isNotEmpty) {
                      ref.read(crudProvider.notifier).commentPost(
                          postId: post.id,
                          comment: Comment(
                              userName: user.firstName!,
                              userImage: user.imageUrl!,
                              comment: val));
                    }
                  },
                ),
                Expanded(
                    child: posts.when(
                        data: (data) {
                          final currentPost = data
                              .firstWhere((element) => element.id == post.id);
                          return Column(
                            children: currentPost.comments.map((e) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(e.userImage),
                                ),
                                title: Text(e.userName),
                                subtitle: Text(e.comment),
                              );
                            }).toList(),
                          );
                        },
                        error: (err, stack) => Text('$err'),
                        loading: () =>
                            const Center(child: CircularProgressIndicator())))
              ],
            );
          }),
        ),
      ),
    );
  }
}
