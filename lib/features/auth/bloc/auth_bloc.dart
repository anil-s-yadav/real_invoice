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


class SignInWithEmailRequestedEvent extends AuthEvent {
  final String email;
  final String password;
  final String? name;
  const SignInWithEmailRequestedEvent(this.email, this.password, {this.name});
  
  @override
  List<Object?> get props => [email, password, name];
}

class SignInWithAppleRequestedEvent extends AuthEvent {
  const SignInWithAppleRequestedEvent();
}

class SignOutRequestedEvent extends AuthEvent {
  const SignOutRequestedEvent();
}

class ForceLoginOnDeviceEvent extends AuthEvent {
  final AuthUser user;
  const ForceLoginOnDeviceEvent(this.user);
}

class LogOutAllDevicesRequestedEvent extends AuthEvent {
  const LogOutAllDevicesRequestedEvent();
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

class AuthDeviceLimitReached extends AuthState {
  final AuthUser user;
  const AuthDeviceLimitReached(this.user);
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
        try {
          await authRepository.registerDevice();
          emit(Authenticated(user: user));
        } on DeviceLimitException {
          emit(AuthDeviceLimitReached(user));
        } catch (e) {
          emit(Authenticated(user: user)); // fallback
        }
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
          try {
            await authRepository.registerDevice();
            emit(Authenticated(user: user));
          } on DeviceLimitException {
            emit(AuthDeviceLimitReached(user));
          }
        } else {
          emit(const Unauthenticated());
        }
      } catch (e) {
        String msg = 'Failed to sign in with Google: $e';
        if (e.toString().contains('ApiException: 10')) {
          msg =
              'Google Sign-In configuration error (ApiException: 10). Add your SHA-1 fingerprint in Firebase Console.';
        }
        emit(AuthError(msg));
        emit(const Unauthenticated());
      }
    });

    
    on<SignInWithEmailRequestedEvent>((event, emit) async {
      try {
        emit(const AuthLoading());
        final user = await authRepository.signInWithEmailAndPassword(
          event.email, 
          event.password, 
          name: event.name,
        );
        emit(Authenticated(user: user));
      } catch (e) {
        emit(AuthError(e.toString()));
        emit(const Unauthenticated());
      }
    });

    on<SignInWithAppleRequestedEvent>((event, emit) async {
      emit(const AuthLoading());
      try {
        final user = await authRepository.signInWithApple();
        try {
          await authRepository.registerDevice();
          emit(Authenticated(user: user));
        } on DeviceLimitException {
          emit(AuthDeviceLimitReached(user));
        }
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

    on<ForceLoginOnDeviceEvent>((event, emit) async {
      emit(const AuthLoading());
      try {
        await authRepository.registerDevice(force: true);
        emit(Authenticated(user: event.user));
      } catch (e) {
        emit(AuthError('Failed to switch device.'));
        emit(const Unauthenticated());
      }
    });
    on<LogOutAllDevicesRequestedEvent>((event, emit) async {
      emit(const AuthLoading());
      try {
        await authRepository.logOutAllDevices();
        emit(const Unauthenticated());
      } catch (e) {
        emit(AuthError('Failed to log out all devices: $e'));
        emit(const Unauthenticated());
      }
    });
  }
}
