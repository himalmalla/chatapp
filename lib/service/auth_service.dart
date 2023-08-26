import 'dart:io';
import 'package:chatapp/common_provider/firebase_instances.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

final authService = Provider(
  (ref) => AuthService(
      auth: ref.watch(auth),
      messaging: ref.watch(msg),
      chatCore: ref.watch(chatCore),
      storage: ref.watch(storage)),
);

class AuthService {
  final FirebaseAuth auth;
  final FirebaseMessaging messaging;
  final FirebaseChatCore chatCore;
  final FirebaseStorage storage;

  AuthService(
      {required this.auth,
      required this.messaging,
      required this.chatCore,
      required this.storage});

  Future<Either<String, bool>> userLogin(
      {required String email, required String password}) async {
    try {
      // final token = await messaging.getToken();
      final response = await auth.signInWithEmailAndPassword(
          email: email, password: password);

      return Right(true);
    } on FirebaseAuthException catch (err) {
      return Left(err.message.toString());
    } catch (err) {
      return Left(err.toString());
    }
  }

  Future<Either<String, bool>> userSignUp(
      {required String email,
      required String password,
      required String userName,
      required XFile image}) async {
    try {
      final ref = storage.ref().child('userImages/${image.name}');
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();
      final token = await messaging.getToken();
      final response = await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      chatCore.createUserInFirestore(types.User(
          id: response.user!.uid,
          firstName: userName,
          imageUrl: url,
          metadata: {'email': email, 'token': token}));

      return Right(true);
    } on FirebaseAuthException catch (err) {
      return Left(err.message.toString());
    } on FirebaseException catch (err) {
      return Left(err.message.toString());
    } catch (err) {
      return Left(err.toString());
    }
  }

  Future<Either<String, bool>> userLogOut() async {
    try {
      final response = await auth.signOut();

      return Right(true);
    } on FirebaseAuthException catch (err) {
      return Left(err.message.toString());
    } catch (err) {
      return Left(err.toString());
    }
  }
}
