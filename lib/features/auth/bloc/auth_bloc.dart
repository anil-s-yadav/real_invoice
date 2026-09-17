import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStartedEvent extends AuthEvent {
  const AppStartedEvent();
}

class SignInRequestedEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInRequestedEvent(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
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
  final String userId;
  final String? email;
  final String? displayName;

  const Authenticated({
    required this.userId,
    this.email,
    this.displayName,
  });

  @override
  List<Object?> get props => [userId, email, displayName];
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

// BLoC (Offline guest by default, ready for Firebase Auth)
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const Unauthenticated()) {
    on<AppStartedEvent>((event, emit) {
      // In V1 offline-first mode, user operates seamlessly without forced login
      emit(const Unauthenticated());
    });
    on<SignInRequestedEvent>((event, emit) async {
      emit(const AuthLoading());
      // Hook ready for: await FirebaseAuth.instance.signInWithEmailAndPassword(...)
      emit(Authenticated(userId: 'local_user', email: event.email));
    });
    on<SignOutRequestedEvent>((event, emit) async {
      emit(const Unauthenticated());
    });
  }
}
