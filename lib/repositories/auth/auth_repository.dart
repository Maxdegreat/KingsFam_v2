import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/auth/base_auth_repository.dart';
import 'package:kingsfam/repositories/extraTools.dart';

class AuthRepository extends BaseAuthRepository {
  //class data
  final FirebaseFirestore _firebaseFirestore;
  final auth.FirebaseAuth _firebaseAuth;
  final FirebaseMessaging _messaging;

  //constructor
  AuthRepository({
    FirebaseFirestore? firebaseFirestore,
    auth.FirebaseAuth? firebaseAuth,
    FirebaseMessaging? messaging,
  })  : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance,
        _messaging = messaging ?? FirebaseMessaging.instance;

  @override
  Stream<auth.User?> get user => _firebaseAuth.userChanges();
  auth.User? currUser;

  //                                                           Save a users new token to a the database
   Future<void> saveTokenToDatabase(String token) async {
      
      String userId = currUser!.uid;
      if(currUser == null) {
        String? userId;
        print("***************************");
        print("The currUser in saveTokenToDataBase is null in Auth_repo");
        print("****************************");
        exit(-1);
      }

       await FirebaseFirestore.instance
       .collection('users')
       .doc(userId)
       .update({'token': FieldValue.arrayUnion([token])});
}



  //                                                          sign up with email and password
  @override
  Future<auth.User> signUpWithEmailAndPassword({required String username, required String email, required String password}) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      final user = credential.user;
      final List<String> usernameSearchCase = AdvancedQuerry().advancedSearch(query: username);
      // String? token = await _messaging.getToken();
      _firebaseFirestore.collection(Paths.users).doc(user!.uid).set({
        'username': username,
        'email': email,
        'usernameSearchCase': usernameSearchCase,
        'token': [],
        'colorPref': '#9814F4'
      });

  currUser = credential.user;
  String? token = await FirebaseMessaging.instance.getToken();
  await saveTokenToDatabase(token!);
  FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);



      return user;
    } on auth.FirebaseAuthException catch (e) {
      throw Failure(code: e.code, message: e.message!);
    } on PlatformException catch (e) {
      throw Failure(code: e.code, message: e.message!);
    }
  }

  //-------------------------------------------------------------------------------- login with email and password
  @override
  Future<auth.User> loginWithEmailAndPassword({ required String email, required String password }) async {
    try {

      final credential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      currUser = credential.user;
      String? token = await FirebaseMessaging.instance.getToken();
      await saveTokenToDatabase(token!);
      FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);

      return credential.user!;

    } on auth.FirebaseAuthException catch (e) {

      throw Failure(code: e.code, message: e.message!);

    } on PlatformException catch (e) {

      throw Failure(code: e.code, message: e.message!);
    }
  }

  // --------------------------------------------------------------------------  Google Sign in 

  //GoogleSignInAccount get socalUser => googleUser;

  final googleSignIn = GoogleSignIn();
  // Stream<auth.User?> get user => _firebaseAuth.userChanges();
  // Stream<auth.UserCredential> get googleUser =>
  //     _firebaseAuth.authStateChanges();

  @override
  Future<auth.User?> signInWithGoogle() async {
    auth.User? user;
    //trigger auth flow
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    //obtain auth details from request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    //create a new crediental
    final crediential = auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      final auth.UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(crediential);
      user = userCredential.user;

      final List<String> usernameSearchCase =
          AdvancedQuerry().advancedSearch(query: googleUser.displayName!);

      if (userCredential.additionalUserInfo!.isNewUser) {
        String? token = await _messaging.getToken();
        _firebaseFirestore.collection(Paths.users).doc(user!.uid).set({
          'profileImage': user.photoURL,
          'username': user.displayName,
          'usernameSearchCase': usernameSearchCase,
          'email': user.email,
          'followers': 0,
          'following': 0,
          'token': [token],
          'colorPref': '#9814F4',
        });
      }

    currUser = userCredential.user;
    String? token = await FirebaseMessaging.instance.getToken();
    await saveTokenToDatabase(token!);
    FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);

      return user;
    } on auth.FirebaseAuthException catch (e) {
      throw Failure(code: e.code, message: e.message!);
    } on PlatformException catch (e) {
      throw Failure(code: e.code, message: e.message!);
    }
  }

  //log out of app
  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    final signedIn = await googleSignIn.isSignedIn();
    if (signedIn) {
      await googleSignIn.disconnect();
      await _firebaseAuth.signOut();
    }
  }
}





























//  final googleSignIn = GoogleSignIn();
//   // Stream<auth.User?> get user => _firebaseAuth.userChanges();
//   Stream<auth.UserCredential> get googleUser => _firebaseAuth.authStateChanges();

//   @override
//   Future<auth.UserCredential> signInWithGoogle() async {
//     //trigger auth flow
//     final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    
//     //obtain auth details from request
//     final GoogleSignInAuthentication googleAuth =
//         await googleUser!.authentication;

//     //create a new crediental
//     final credential = auth.GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     String? token = await _messaging.getToken();
//     _firebaseFirestore.collection(Paths.users).doc(googleUser.id).set({
//       'profileImage': googleUser.photoUrl,
//       'username': googleUser.displayName,
//       'email': googleUser.email,
//       'followers': 0,
//       'following': 0,
//       'token': token,
//     });
//     //once signed in return user crediental
//     return await _firebaseAuth.signInWithCredential(credential);
//   }
