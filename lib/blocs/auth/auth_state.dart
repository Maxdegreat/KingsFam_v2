part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenicated }

class AuthState extends Equatable {
  final auth.User? user;
  final AuthStatus status;
  final bool? isUserNew;

  const AuthState({
    this.user,
    this.status = AuthStatus.unknown,
    this.isUserNew,
  });

  factory AuthState.unknown() => AuthState();

  factory AuthState.authenicated({required auth.User user, required bool? isNew}) {
    return AuthState(user: user, status: AuthStatus.authenticated, isUserNew: isNew);
  }

  factory AuthState.unauthenicated() =>
      const AuthState(status: AuthStatus.unauthenicated);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [user, status, isUserNew];

  AuthState copyWith({
    auth.User? user,
    AuthStatus? status,
    bool? isUserNew,
  }) {
    return AuthState(
      user: user ?? this.user,
      status: status ?? this.status,
      isUserNew: isUserNew ?? this.isUserNew
    );
  }
}
