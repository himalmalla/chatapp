import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final isLogin = StateProvider<bool>((ref) => true);

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
