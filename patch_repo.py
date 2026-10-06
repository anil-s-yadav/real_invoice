with open('d:/real_invoice/lib/features/auth/data/auth_repository.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Add to interface
text = text.replace("Future<AuthUser> signInWithApple();", "Future<AuthUser> signInWithApple();\n  Future<AuthUser> signInWithEmailAndPassword(String email, String password);")

# Add implementation
impl = """
  @override
  Future<AuthUser> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithCredential(
        EmailAuthProvider.credential(email: email, password: password)
      );
      return _mapFirebaseUser(userCredential.user!);
    } catch (e) {
      throw Exception('Failed to sign in with email: $e');
    }
  }
"""
text = text.replace("Future<AuthUser> signInWithApple() async {", impl + "\n  @override\n  Future<AuthUser> signInWithApple() async {")

with open('d:/real_invoice/lib/features/auth/data/auth_repository.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("auth_repository.dart patched")