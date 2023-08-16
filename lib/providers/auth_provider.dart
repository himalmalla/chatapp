import 'package:chatapp/models/common_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/auth_service.dart';





class AuthProvider extends StateNotifier <CommonState> {
  final AuthService service;
  AuthProvider(super.state, this.service);

  Future<void> userLogin(
      {required String email,
        required String password
      }) async {
    final response = await service.userLogin(email: email, password: password);
  }

}