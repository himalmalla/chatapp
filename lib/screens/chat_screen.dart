import 'dart:io';

import 'package:chatapp/providers/room_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends ConsumerStatefulWidget {
  final types.Room room;
  ChatPage(this.room);

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  @override
  Widget build(BuildContext context) {
    final msg = ref.watch(messageStream(widget.room));
    return Scaffold(
        body: msg.when(
      data: (data) {
        return Chat(
          messages: data,
          onAttachmentPressed: () {
            final ImagePicker picker = ImagePicker();
            picker.pickImage(source: ImageSource.gallery).then((val) async {
              if (val != null) {
                final ref = FirebaseStorage.instance
                    .ref()
                    .child('chatImage/${val.name}');
                await ref.putFile(File(val.path));
                final url = await ref.getDownloadURL();
                final bytes = File(val.path).lengthSync();
                final imageData =
                    types.PartialImage(uri: url, name: val.name, size: bytes);
                FirebaseChatCore.instance
                    .sendMessage(imageData, widget.room.id);
              }
            });
          },
          onSendPressed: (val) {
            FirebaseChatCore.instance
                .sendMessage(types.PartialText(text: val.text), widget.room.id);
          },
          user: types.User(id: FirebaseAuth.instance.currentUser!.uid),
          showUserAvatars: true,
          showUserNames: true,
        );
      },
      error: (err, s) => Container(),
      loading: () => const Center(child: CircularProgressIndicator()),
    ));
  }
}
