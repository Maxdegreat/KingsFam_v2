part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenicated }

class AuthState extends Equatable {
  final auth.User? user;
  final AuthStatus status;
  final Userr? userr;

  const AuthState({
    this.user,
    this.status = AuthStatus.unknown,
    required this.userr,
  });

  factory AuthState.unknown() => AuthState(userr: null);

  factory AuthState.authenicated({required auth.User user}) { // ------------> can add required user as pram then pass to return AuthState
    return AuthState(user: user, status: AuthStatus.authenticated, userr: null);
  }

  factory AuthState.unauthenicated() =>
      const AuthState(status: AuthStatus.unauthenicated, userr: null);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [user, status, userr];

  AuthState copyWith({
    auth.User? user,
    AuthStatus? status,
    Userr? userr,
  }) {
    return AuthState(
      user: user ?? this.user,
      status: status ?? this.status,
      userr: userr ?? this.userr
    );
  }
}
