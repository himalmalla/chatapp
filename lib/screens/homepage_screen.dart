import 'package:chatapp/common_provider/firebase_instances.dart';
import 'package:chatapp/common_widgets/snack_shows.dart';
import 'package:chatapp/constants/sizes.dart';
import 'package:chatapp/providers/auth_provider.dart';
import 'package:chatapp/providers/crud_provider.dart';
import 'package:chatapp/screens/add_screen.dart';
import 'package:chatapp/screens/detail_screen.dart';
import 'package:chatapp/screens/recent_chats_screen.dart';
import 'package:chatapp/screens/update_screen.dart';
import 'package:chatapp/screens/user_detail_screen.dart';
import 'package:chatapp/service/auth_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:chatapp/service/crud_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../notification_service.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  types.User? logUser;

  @override
  void initState() {
    super.initState();

// 1. This method call when app in terminated state and you get a notification
// when you click on notification app open from terminated state and you can get notification data in this method

    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        print("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {
          print("New Notification");
// if (message .data[' id' ] != null){
// Navigator.of (context).push(
// MaterialPageRoute(
// builder: (context) => DemoScreen(
//    id: message.data[' _id' ],
// ),
// ),
// );
// }
          LocalNotificationService.createanddisplaynotification(message);
        }
      },
    );

// 2. This method only call when App in forground it mean app must be opened
    FirebaseMessaging.onMessage.listen(
      (message) {
        print("FirebaseMessaging.onMessage.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message. data11 ${message.data}");
          LocalNotificationService.createanddisplaynotification(message);
        }
      },
    );

// 3. This method only call when App in background and not terminated(not closed)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("FirebaseMessaging.onMessageOpenedApp.listen");
      if (message.notification != null) {
        print(message.notification!.title);
        print(message.notification!.body);
        print("message. data22 ${message.data[' _id']}");
        LocalNotificationService.createanddisplaynotification(message);
      }
    });

    getToken();
  }

  Future<void> getToken() async {
    final response = await FirebaseMessaging.instance.getToken();
    print(response);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final us = ref.watch(auth);
        final users = ref.watch(usersStream);
        final user = ref.watch(singleUser(us.currentUser!.uid));
        final posts = ref.watch(postsStream);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chat App'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                  onPressed: () {
                    Get.to(() => const Recentchats());
                  },
                  icon: const Icon(Icons.messenger_outline_outlined))
            ],
          ),
          drawer: Drawer(
            child: user.whenOrNull(
              data: (data) {
                logUser = data;
                return ListView(
                  children: [
                    DrawerHeader(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.green,
                            image: DecorationImage(
                                image: NetworkImage(data.imageUrl!),
                                fit: BoxFit.cover)),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(data.firstName!),
                    ),
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text('Create post'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Get.to(() => AddPage());
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: Text(data.metadata!['email']),
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout_outlined),
                      title: const Text('Logout'),
                      onTap: () {
                        ref.read(authProvider.notifier).userLogOut();
                      },
                    )
                  ],
                );
              },
            ),
          ),
          body: Column(
            children: [
              Container(
                color: Colors.transparent,
                height: 150,
                width: double.infinity,
                child: users.when(
                    data: (data) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(10),
                            child: InkWell(
                              onTap: () {
                                Get.to(() => UserDetail(data[index]));
                              },
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Column(children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundImage:
                                        NetworkImage(data[index].imageUrl!),
                                  ),
                                  gapH8,
                                  Text(
                                    data[index].firstName!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400),
                                  )
                                ]),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    error: (err, stack) => Center(child: Text('$err')),
                    loading: () => Container()),
              ),
              Expanded(
                  child: posts.when(
                      data: (data) {
                        return ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Text(
                                        data[index].title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      if (us.currentUser!.uid ==
                                          data[index].userId)
                                        Center(
                                          child: IconButton(
                                              onPressed: () {
                                                Get.defaultDialog(
                                                    title: 'Customize Post',
                                                    content: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        IconButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              Get.to(() =>
                                                                  UpdateScreen(
                                                                      data[
                                                                          index]));
                                                            },
                                                            icon: const Icon(
                                                                Icons.edit)),
                                                        IconButton(
                                                            onPressed: () {},
                                                            icon: const Icon(
                                                                Icons.delete)),
                                                        IconButton(
                                                            onPressed: () {},
                                                            icon: const Icon(
                                                                Icons.close)),
                                                      ],
                                                    ));
                                              },
                                              icon:
                                                  const Icon(Icons.more_horiz)),
                                        )
                                    ],
                                  ),
                                ),
                                Image.network(
                                  data[index].imageUrl,
                                  height: 550,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(data[index].detail),
                                ),
                                if (us.currentUser!.uid != data[index].userId)
                                  Row(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            if (data[index]
                                                .like
                                                .usernames
                                                .contains(logUser!.firstName)) {
                                              SnackShow.showError(
                                                  'you have already liked this post');
                                            } else {
                                              ref
                                                  .read(crudProvider.notifier)
                                                  .likePost(
                                                      postId: data[index].id,
                                                      like: data[index]
                                                              .like
                                                              .likes +
                                                          1,
                                                      name:
                                                          logUser!.firstName!);
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.favorite,
                                            color: Colors.pink,
                                          )),
                                      IconButton(
                                          onPressed: () {
                                            Get.to(() => DetailPage(
                                                data[index], logUser!));
                                          },
                                          icon: const Icon(
                                            Icons.comment,
                                            color: Colors.green,
                                          ))
                                    ],
                                  ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(data[index].like.likes == 0
                                      ? ''
                                      : data[index].like.likes.toString() +
                                          'like'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      error: ((err, stack) => Text('$err')),
                      loading: () => const CircularProgressIndicator()))
            ],
          ),
        );
      },
    );
  }
}
