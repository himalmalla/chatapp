import 'package:chatapp/models/common_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/auth_service.dart';

final authProvider = StateNotifierProvider<AuthProvider, CommonState>(
    (ref) => AuthProvider(CommonState.empty(), ref.watch(authService)));

class AuthProvider extends StateNotifier<CommonState> {
  final AuthService service;
  AuthProvider(super.state, this.service);

  Future<void> userLogin(
      {required String email, required String password}) async {
    state = state.copyWith(
        isLoad: true, errtext: '', isError: false, isSuccess: false);
    final response = await service.userLogin(email: email, password: password);
    response.fold((l) {
      (isLoad: false, errtext: l, isError: true, isSuccess: false);
    }, (r) {
      (isLoad: false, errtext: '', isError: false, isSuccess: r);
    });
  }
}
