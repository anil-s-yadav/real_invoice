with open('d:/real_invoice/test/widget_test.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("Future<AuthUser> signInWithApple() async => throw UnimplementedError();", "Future<AuthUser> signInWithApple() async => throw UnimplementedError();\n\n  @override\n  Future<AuthUser> signInWithEmailAndPassword(String email, String password) async => throw UnimplementedError();")

with open('d:/real_invoice/test/widget_test.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("widget_test.dart fixed")