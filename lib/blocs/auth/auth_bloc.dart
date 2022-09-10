import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';

import '../../config/paths.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  late StreamSubscription<auth.User?> _userSubscription;
 
  AuthBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(AuthState.unknown()) {
    
    _userSubscription = _authRepository.user.listen((user) => add(AuthUserChanged(user: user)));
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
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
    if (event.user != null) {
      // var userSnap = await FirebaseFirestore.instance.collection(Paths.users).doc(event.user!.uid).get();
      // var user = Userr.fromDoc(userSnap);
      // ignore: invalid_use_of_visible_for_testing_member
      // emit(state.copyWith(userr: user));
      yield AuthState.authenicated(user: event.user!);
    } else {
      yield AuthState.unauthenicated();
    }
  // ----------- METHODS BELOW -----------------
  
  }
}
