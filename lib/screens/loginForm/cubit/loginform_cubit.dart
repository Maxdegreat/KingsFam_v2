import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/auth/auth_repository.dart';

part 'loginform_state.dart';

class LoginformCubit extends Cubit<LoginformState> {
  final AuthRepository _authRepository;
  LoginformCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(LoginformState.initial());
  //will fire when we change text in the email feild
  void emailChanged(String Value) {
    emit(state.copyWith(email: Value, status: LoginStatus.initial));
  }

  void passwordChanged(String Value) {
    emit(state.copyWith(password: Value, status: LoginStatus.initial));
  }

  void loginWithCredientials() async {
    //make sure login does not fire when state.status is currently submitting
    if (!state.isFormValid || state.status == LoginStatus.submitting ) return;
    emit(state.copyWith(status: LoginStatus.submitting));
    try {
      await _authRepository.loginWithEmailAndPassword(
          email: state.email, password: state.password);
      emit(state.copyWith(status: LoginStatus.success));
    } on Failure catch (e) {
      emit(state.copyWith(failure: e, status: LoginStatus.error));
    }
  }
}
