import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:get/get_connect.dart';
import 'package:image_picker/image_picker.dart';

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
      final Response = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return Right(true);
    } on FirebaseAuthException catch (err) {
      return Left(err.message.toString());
    } catch (err) {
      return Left(err.toString());
    }
  }
}
