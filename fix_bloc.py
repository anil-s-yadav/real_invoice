import re

with open('d:/real_invoice/lib/features/auth/bloc/auth_bloc.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("emit(Authenticated(user));", "emit(Authenticated(user: user));")
text = text.replace("emit(Unauthenticated());", "emit(const Unauthenticated());")

with open('d:/real_invoice/lib/features/auth/bloc/auth_bloc.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("auth_bloc.dart fixed")