import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intern01/repositories/auth_repository.dart';
import 'package:intern01/bloc/auth/auth_event.dart';
import 'package:intern01/bloc/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthCall _authCall = AuthCall();
  AuthBloc() : super(AuthInitial()) {
    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authCall.signOut();
        emit(AuthInitial());
      } catch (e) {
        emit(AuthError(message: "Logout failed"));
      }
    });
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _authCall.loginAsEmailPassword(
          event.email,
          event.password,
        );
        emit(AuthSuccess(email: result.email, role: result.role));
      } catch (e) {
        String errorMsg = "Login failed";
        if (e is FirebaseAuthException) {
          errorMsg = e.message ?? errorMsg;
        } else if (e is Exception) {
          errorMsg = e.toString().replaceAll('Exception: ', '');
        }
        emit(AuthError(message: errorMsg));
      }
    });

    on<SignupRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _authCall.signUpEmailPassword(
          event.email,
          event.password,
          event.role,
        );

        if (result != null) {
          emit(AuthSuccess(email: result.email, role: result.role));
        } else {
          emit(AuthError(message: "Signup failed - no user data returned"));
        }
      } catch (e) {
        String errorMsg = "Signup failed";
        if (e is FirebaseAuthException) {
          errorMsg = e.message ?? errorMsg;
        } else if (e is Exception) {
          errorMsg = e.toString().replaceAll('Exception: ', '');
        }
        emit(AuthError(message: errorMsg));
      }
    });

    on<CheckAuthStatusEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final userModel = await _authCall.getCurrentUserWithRole(
            currentUser.uid,
          );
          if (userModel != null) {
            emit(AuthSuccess(email: userModel.email, role: userModel.role));
          } else {
            emit(AuthInitial());
          }
        } else {
          emit(AuthInitial());
        }
      } catch (e) {
        emit(AuthError(message: "Failed to check authentication status"));
      }
    });
  }
}
