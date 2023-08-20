import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final loginProvider = StateProvider.autoDispose<bool>((ref) => true);
final passHide = StateProvider.autoDispose((ref) => true);

final image = StateNotifierProvider.autoDispose<ImageProvider, XFile?>(
    (ref) => ImageProvider(null));

class ImageProvider extends StateNotifier<XFile?> {
  ImageProvider(super.state);

  final ImagePicker picker = ImagePicker();

  void pickImage(bool isCamera) async {
    if (isCamera) {
      state = await picker.pickImage(source: ImageSource.camera);
    } else {
      state = await picker.pickImage(source: ImageSource.gallery);
    }
  }
}

final mode = StateNotifierProvider.autoDispose<ModeProvider, AutovalidateMode>(
    (ref) => ModeProvider(AutovalidateMode.disabled));

class ModeProvider extends StateNotifier<AutovalidateMode> {
  ModeProvider(super.state);

  void change() {
    state = AutovalidateMode.onUserInteraction;
  }
}
