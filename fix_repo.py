with open('d:/real_invoice/lib/features/auth/data/auth_repository.dart', 'r', encoding='utf-8') as f:
    text = f.read()

impl_old = """  @override
  Future<AuthUser> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithCredential(
        EmailAuthProvider.credential(email: email, password: password)
      );
      return _mapFirebaseUser(userCredential.user!);
    } catch (e) {
      throw Exception('Failed to sign in with email: $e');
    }
  }"""

impl_new = """  @override
  Future<AuthUser> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      final u = _mapFirebaseUser(userCredential.user);
      if (u == null) throw Exception('User mapping failed');
      return u;
    } catch (e) {
      throw Exception('Failed to sign in with email: $e');
    }
  }"""

text = text.replace(impl_old, impl_new)

with open('d:/real_invoice/lib/features/auth/data/auth_repository.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("auth_repository.dart fixed")