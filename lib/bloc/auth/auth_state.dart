abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String email;
  final String role;
  AuthSuccess({required this.email, required this.role});
}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}
