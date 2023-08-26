import 'dart:io';
import 'package:chatapp/common_provider/other_provider.dart';
import 'package:chatapp/common_widgets/snack_shows.dart';
import 'package:chatapp/constants/sizes.dart';
import 'package:chatapp/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class Authpage extends ConsumerWidget {
  Authpage({super.key});

  final userNameController = TextEditingController();
  final mailController = TextEditingController();
  final passController = TextEditingController();
  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, ref) {
    ref.listen(authProvider, (previous, next) {
      if (next.isError) {
        SnackShow.showError(next.errtext);
      } else if (next.isSuccess) {
        SnackShow.showSuccess('Successfully logged in');
      }
    });

    final auth = ref.watch(authProvider);
    final isLogin = ref.watch(loginProvider);
    final mod = ref.watch(mode);
    final pwdHide = ref.watch(passHide);
    final image = ref.watch(imageProvider);

    return Scaffold(
      body: SafeArea(
        child: Form(
          autovalidateMode: mod,
          key: _form,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            child: ListView(
              children: [
                Center(
                  child: Text(
                    isLogin ? 'Login Form' : 'SignUp Form',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ),
                gapH32,
                if (!isLogin)
                  TextFormField(
                    keyboardType: TextInputType.name,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(12),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'Username',
                      suffixIcon: Icon(Icons.person),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Username is required';
                      } else if (val.length < 7) {
                        return 'minimum 6 character required';
                      }
                    },
                    controller: userNameController,
                  ),
                gapH16,
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    suffixIcon: Icon(Icons.email_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'email is required';
                    } else if (!RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(val)) {
                      return 'Please provide valid email';
                    }
                  },
                  controller: mailController,
                ),
                gapH16,
                TextFormField(
                  keyboardType: TextInputType.text,
                  inputFormatters: [LengthLimitingTextInputFormatter(20)],
                  decoration: InputDecoration(
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        ref.read(passHide.notifier).state =
                            !ref.read(passHide.notifier).state;
                      },
                      icon: Icon(pwdHide ? Icons.lock : Icons.lock_open_sharp),
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'password is required';
                    } else if (val.length < 7) {
                      return 'minimum 6 character required';
                    }
                    return null;
                  },
                  obscureText: pwdHide ? true : false,
                  controller: passController,
                ),
                gapH24,
                if (!isLogin)
                  InkWell(
                    onTap: () {
                      Get.defaultDialog(
                          title: 'Choose From',
                          content: Column(
                            children: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    ref
                                        .read(imageProvider.notifier)
                                        .pickImage(true);
                                  },
                                  child: const Text('Camera')),
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    ref
                                        .read(imageProvider.notifier)
                                        .pickImage(false);
                                  },
                                  child: Text('Gallery'))
                            ],
                          ));
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: image == null
                          ? Text('Please select image')
                          : Image.file(File(image.path)),
                    ),
                  ),
                gapH16,
                ElevatedButton(
                  onPressed: auth.isLoad
                      ? null
                      : () {
                          FocusScope.of(context).unfocus();
                          _form.currentState!.save();
                          if (_form.currentState!.validate()) {
                            if (isLogin) {
                              ref.read(authProvider.notifier).userLogin(
                                    email: mailController.text.trim(),
                                    password: passController.text.trim(),
                                  );
                            } else {
                              if (image == null) {
                                SnackShow.showError('please select an image');
                              } else {
                                ref.read(authProvider.notifier).userSignUp(
                                    email: mailController.text.trim(),
                                    password: passController.text.trim(),
                                    userName: userNameController.text.trim(),
                                    image: image);
                              }
                            }
                          } else {
                            ref.read(mode.notifier).change();
                          }
                        },
                  child: auth.isLoad
                      ? const CircularProgressIndicator()
                      : const Text('Submit'),
                ),
                Row(
                  children: [
                    Text(isLogin
                        ? 'Don\'t have an account'
                        : 'Already have an account'),
                    TextButton(
                      onPressed: () {
                        ref.read(loginProvider.notifier).state =
                            !ref.read(loginProvider.notifier).state;
                      },
                      child: Text(isLogin ? 'Sign Up' : 'Login'),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
