import 'package:chatapp/common_provider/firebase_instances.dart';
import 'package:chatapp/models/common_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../service/auth_service.dart';

final authProvider = StateNotifierProvider<AuthProvider, CommonState>(
    (ref) => AuthProvider(CommonState.empty(), ref.watch(authService)));

final userStream =
    StreamProvider.autoDispose((ref) => ref.read(auth).authStateChanges());

class AuthProvider extends StateNotifier<CommonState> {
  final AuthService service;
  AuthProvider(super.state, this.service);

  Future<void> userLogin(
      {required String email, required String password}) async {
    state = state.copyWith(
        isLoad: true, errtext: '', isError: false, isSuccess: false);
    final response = await service.userLogin(email: email, password: password);
    response.fold((l) {
      state = state.copyWith(
          isLoad: false, errtext: l, isError: true, isSuccess: false);
    }, (r) {
      state = state.copyWith(
          isLoad: false, errtext: '', isError: false, isSuccess: r);
    });
  }

  Future<void> userSignUp(
      {required String email,
      required String password,
      required String userName,
      required XFile image}) async {
    state = state.copyWith(
        isLoad: true, errtext: '', isError: false, isSuccess: false);

    final response = await service.userSignUp(
        email: email, password: password, userName: userName, image: image);
    response.fold((l) {
      state = state.copyWith(
          isLoad: false, errtext: l, isError: true, isSuccess: false);
    }, (r) {
      state = state.copyWith(
          isLoad: false, errtext: '', isError: false, isSuccess: r);
    });
  }

  Future<void> userLogOut() async {
    state = state.copyWith(
        isLoad: true, errtext: '', isError: false, isSuccess: false);

    final response = await service.userLogOut();
    response.fold((l) {
      state = state.copyWith(
          isLoad: false, errtext: l, isError: true, isSuccess: false);
    }, (r) {
      state = state.copyWith(
          isLoad: false, errtext: '', isError: false, isSuccess: r);
    });
  }
}
