import 'package:firebase_auth/firebase_auth.dart' as auth;

//this is the base to the actual auth repository!!!
abstract class BaseAuthRepository {
  //stream that will be used to listen for the user
  Stream<auth.User?> get user;
  //sign up with email and password function
  Future<auth.User> signUpWithEmailAndPassword({
    required String username,
    required String email,
    required String password,
  });
  //login with email and password
  Future<auth.User> loginWithEmailAndPassword({
    required String email,
    required String password,
  });
  //login with google
  Future<auth.User?> signInWithGoogle();
  //simple function that calls the log out function
  Future<void> logout();
}
