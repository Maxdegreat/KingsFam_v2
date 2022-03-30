part of 'signupform_cubit.dart';

enum SignupStatus { initial, submiting, success, error }

class SignupformState extends Equatable {
  final String username;
  final String email;
  final String password;
  final SignupStatus status;
  final Failure failure;

  bool get isFormValid => username.isNotEmpty && email.isNotEmpty && password.isNotEmpty;

  const SignupformState(
      {required this.username,
      required this.email,
      required this.password,
      required this.status,
      required this.failure});

  factory SignupformState.initial() {
    return SignupformState(
        username: '',
        email: '',
        password: '',
        status: SignupStatus.initial,
        failure: Failure());
  }

  @override
  bool? get stringify => true;

  @override
  List<Object> get props => [username, email, password, status, failure];

  SignupformState copyWith({
    String? username,
    String? email,
    String? password,
    SignupStatus? status,
    Failure? failure,
  }) {
    return SignupformState(
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}
