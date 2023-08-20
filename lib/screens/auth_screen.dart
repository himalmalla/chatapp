import 'package:chatapp/common_provider/other_provider.dart';
import 'package:chatapp/constants/sizes.dart';
import 'package:chatapp/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      } else if (next.isSuccess) {}
    });

    final auth = ref.watch(authProvider);
    final isLogin = ref.watch(loginProvider);
    final mod = ref.watch(mode);
    final pwdHide = ref.watch(passHide);

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
                gapH16,
                if (!isLogin)
                  InkWell(
                    onTap: () {},
                    child: Container(),
                  ),
                ElevatedButton(
                  onPressed: auth.isLoad
                      ? null
                      : () {
                          _form.currentState!.save();
                          if (_form.currentState!.validate()) {
                            ref.read(authProvider.notifier).userLogin(
                                  email: mailController.text.trim(),
                                  password: passController.text.trim(),
                                );
                          } else {
                            ref.read(mode.notifier).change();
                          }
                        },
                  child: auth.isLoad
                      ? const CircularProgressIndicator()
                      : const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
