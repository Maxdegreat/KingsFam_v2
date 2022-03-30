part of 'loginform_cubit.dart';

enum LoginStatus { initial, submitting, success, error }
//initial empty when email and password are empty
//submitting when user submits there login
//sucess login to nav
//faolure when an error has occoured

class LoginformState extends Equatable {
  final String email;
  final String password;
  final LoginStatus status;
  final Failure failure;

  bool get isFormValid => email.isNotEmpty && password.isNotEmpty;

  const LoginformState(
      {required this.email,
      required this.password,
      required this.status,
      required this.failure});

  factory LoginformState.initial() {
    return LoginformState(
        email: '',
        password: '',
        status: LoginStatus.initial,
        failure: Failure());
  }

  @override
  bool? get stringify => true;

  @override
  List<Object> get props => [email, password, status, failure];

  LoginformState copyWith({
    String? email,
    String? password,
    LoginStatus? status,
    Failure? failure,
  }) {
    return LoginformState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}
