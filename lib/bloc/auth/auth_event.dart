abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested({required this.email, required this.password});
}

class SignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String role;
  SignupRequested({
    required this.email,
    required this.password,
    required this.role,
  });
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}
