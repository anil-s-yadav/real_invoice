import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/auth_repository.dart';
import '../domain/auth_user_model.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStartedEvent extends AuthEvent {
  const AppStartedEvent();
}

class AuthUserChangedEvent extends AuthEvent {
  final AuthUser? user;
  const AuthUserChangedEvent(this.user);

  @override
  List<Object?> get props => [user];
}

class SignInWithGoogleRequestedEvent extends AuthEvent {
  const SignInWithGoogleRequestedEvent();
}

class SignInWithAppleRequestedEvent extends AuthEvent {
  const SignInWithAppleRequestedEvent();
}

class SignOutRequestedEvent extends AuthEvent {
  const SignOutRequestedEvent();
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final AuthUser user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<AppStartedEvent>((event, emit) async {
      emit(const AuthLoading());
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(const Unauthenticated());
      }
    });

    on<AuthUserChangedEvent>((event, emit) {
      if (event.user != null) {
        emit(Authenticated(user: event.user!));
      } else {
        emit(const Unauthenticated());
      }
    });

    on<SignInWithGoogleRequestedEvent>((event, emit) async {
      emit(const AuthLoading());
      try {
        final user = await authRepository.signInWithGoogle();
        if (user != null) {
          emit(Authenticated(user: user));
        } else {
          emit(const Unauthenticated());
        }
      } catch (e) {
        String msg = 'Failed to sign in with Google: $e';
        if (e.toString().contains('ApiException: 10')) {
          msg = 'Google Sign-In configuration error (ApiException: 10). Add your SHA-1 fingerprint in Firebase Console.';
        }
        emit(AuthError(msg));
        emit(const Unauthenticated());
      }
    });

    on<SignInWithAppleRequestedEvent>((event, emit) async {
      emit(const AuthLoading());
      try {
        final user = await authRepository.signInWithApple();
        emit(Authenticated(user: user));
      } catch (e) {
        emit(AuthError('Failed to sign in with Apple: $e'));
        emit(const Unauthenticated());
      }
    });

    on<SignOutRequestedEvent>((event, emit) async {
      emit(const AuthLoading());
      await authRepository.signOut();
      emit(const Unauthenticated());
    });
  }
}
