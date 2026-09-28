import 'dart:io';

void main() async {
  // A tiny 1x1 transparent PNG base64
  const String base64Png =
      "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=";

  final bytes = Uri.parse(
    "data:image/png;base64,$base64Png",
  ).data!.contentAsBytes();

  final names = ['free_template_thumb.png', 'paid_template_thumb.png'];

  for (var name in names) {
    final file = File('assets/images/templates/$name');
    await file.writeAsBytes(bytes);
    print('Created $name');
  }
}
