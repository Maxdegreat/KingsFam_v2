import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';

part 'signupform_state.dart';

class SignupformCubit extends Cubit<SignupformState> {
  final AuthRepository _authRepository;

  SignupformCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(SignupformState.initial());

  //will fire when text field is changed
  void usernameChanged(String value) {
    emit(state.copyWith(username: value, status: SignupStatus.initial));
  }

  //will fire when the email is changed
  void emailChanged(String value) {
    emit(state.copyWith(email: value, status: SignupStatus.initial));
  }

  //will fire when the password is changed
  void passwordChanged(String value) {
    emit(state.copyWith(password: value, status: SignupStatus.initial));
  }

  //will fire if username is taken
  //  void onUsernameIsTaken() {
  //    emit(state.copyWith(status: SignupStatus.error, failure: Failure(message: "This Username is taken alredy")));
  //  }

  //this is the submit func that calls the Bloc and creates a new user
  void signUpWithCredientials() async {
    if (!state.isFormValid || state.status == SignupStatus.submiting) return;
    emit(state.copyWith(status: SignupStatus.submiting));
    try {
      await _authRepository.signUpWithEmailAndPassword(
          username: state.username,
          email: state.email,
          password: state.password);
      emit(state.copyWith(status: SignupStatus.success));
    } on Failure catch (e) {
      emit(state.copyWith(failure: e, status: SignupStatus.error));
    }
  }
}
