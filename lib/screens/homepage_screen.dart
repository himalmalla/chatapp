import 'package:chatapp/common_provider/firebase_instances.dart';
import 'package:chatapp/providers/auth_provider.dart';
import 'package:chatapp/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final us = ref.watch(auth);
        final users = ref.watch(usersStream);
        final user = ref.watch(singleUser(us.currentUser!.uid));
        return Scaffold(
          appBar: AppBar(
            title: const Text('Chat App'),
            backgroundColor: Colors.green,
          ),
          drawer: Drawer(
            child: user.whenOrNull(
              data: (data) {
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
                      onTap: () {
                        ref.read(authProvider.notifier).userLogOut();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: Text(data.metadata!['email']),
                      onTap: () {
                        ref.read(authProvider.notifier).userLogOut();
                      },
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
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: Column(children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                      NetworkImage(data[index].imageUrl!),
                                ),
                                Text(data[index].firstName!)
                              ]),
                            ),
                          );
                        },
                      );
                    },
                    error: (err, stack) => Center(child: Text('$err')),
                    loading: () => Container()),
              ),
            ],
          ),
        );
      },
    );
  }
}
