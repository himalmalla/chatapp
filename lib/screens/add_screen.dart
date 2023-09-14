import 'dart:io';
import 'package:chatapp/common_provider/other_provider.dart';
import 'package:chatapp/common_widgets/snack_shows.dart';
import 'package:chatapp/constants/sizes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../providers/crud_provider.dart';

class AddPage extends ConsumerWidget {
  final titleController = TextEditingController();
  final detailController = TextEditingController();
  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, ref) {
    ref.listen(crudProvider, (previous, next) {
      if (next.isError) {
        SnackShow.showError(next.errtext);
      } else if (next.isSuccess) {
        Get.back();
        SnackShow.showSuccess('Success');
      }
    });

    final auth = ref.watch(crudProvider);
    final mod = ref.watch(mode);
    final image = ref.watch(imageProvider);

    return WillPopScope(
      onWillPop: () async {
        if (auth.isLoad) {
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Form(
            autovalidateMode: mod,
            key: _form,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: ListView(
                children: [
                  const Center(
                    child: Text(
                      'Add Form',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                  ),
                  gapH32,
                  TextFormField(
                    keyboardType: TextInputType.name,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(12),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'Title',
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'title is required';
                      }
                    },
                    controller: titleController,
                  ),
                  gapH16,
                  TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: 'Detail',
                    ),
                    textInputAction: TextInputAction.done,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Detail is required';
                      }
                      return null;
                    },
                    controller: detailController,
                  ),
                  gapH24,
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
                                child: const Text('Gallery'))
                          ],
                        ),
                      );
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: image == null
                          ? const Center(child: Text('Please select an image'))
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
                              if (image == null) {
                                SnackShow.showError('please select an image');
                              } else {
                                ref.read(crudProvider.notifier).createPost(
                                    title: titleController.text.trim(),
                                    detail: detailController.text.trim(),
                                    userId:
                                        FirebaseAuth.instance.currentUser!.uid,
                                    image: image);
                              }
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
      ),
    );
  }
}
