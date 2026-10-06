with open('d:/real_invoice/lib/features/auth/bloc/auth_bloc.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Add event
event = """
class SignInWithEmailRequestedEvent extends AuthEvent {
  final String email;
  final String password;
  const SignInWithEmailRequestedEvent(this.email, this.password);
  
  @override
  List<Object> get props => [email, password];
}
"""
text = text.replace("class SignInWithAppleRequestedEvent extends AuthEvent {", event + "\nclass SignInWithAppleRequestedEvent extends AuthEvent {")

# Add handler
handler = """
    on<SignInWithEmailRequestedEvent>((event, emit) async {
      try {
        emit(AuthLoading());
        final user = await authRepository.signInWithEmailAndPassword(event.email, event.password);
        emit(Authenticated(user));
      } catch (e) {
        emit(AuthError(e.toString()));
        emit(Unauthenticated());
      }
    });
"""
text = text.replace("on<SignInWithAppleRequestedEvent>((event, emit) async {", handler + "\n    on<SignInWithAppleRequestedEvent>((event, emit) async {")

with open('d:/real_invoice/lib/features/auth/bloc/auth_bloc.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("auth_bloc.dart patched")