import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';

import '../../config/paths.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  late StreamSubscription<auth.User?> _userSubscription;
  late StreamSubscription<bool?> _isNewUserSubscription;
  AuthBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(AuthState.unknown()) {
    _isNewUserSubscription = _authRepository.isNewUser.listen((isNew) => state.copyWith(isUserNew: isNew));      
    _userSubscription = _authRepository.user.listen((user) => add(AuthUserChanged(user: user)));
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }

  Stream<AuthState> newUserKnown() async* {
    yield state.copyWith(isUserNew: false);
  }

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if (event is AuthUserChanged) {
      yield* _mapAuthUserChangedToState(event);
    } else if (event is AuthLogoutRequested) {
      await _authRepository.logout();
    }
  }

  Stream<AuthState> _mapAuthUserChangedToState(AuthUserChanged event) async* {
    // FirebaseFirestore.instance.collection(Paths.users).doc(state.user!.uid).get();
    yield event.user != null
        ? AuthState.authenicated(user: event.user!, isNew: state.isUserNew)
        : AuthState.unauthenicated();
  }
}
