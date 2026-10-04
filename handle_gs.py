import re

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# I need to add FirebaseStorage import if it's not there.
if "import 'package:firebase_storage/firebase_storage.dart';" not in content:
    content = content.replace("import 'package:pdf/pdf.dart';", "import 'package:pdf/pdf.dart';\nimport 'package:firebase_storage/firebase_storage.dart';")

# I will rewrite the _fetchImageBytes method.
fetch_pattern = r"static Future<Uint8List\?> _fetchImageBytes\(String path\) async \{[\s\S]*?return null;\s*\}"

new_fetch = """static Future<Uint8List?> _fetchImageBytes(String path) async {
    if (path.isEmpty) return null;
    if (_imageCache.containsKey(path)) return _imageCache[path];

    try {
      String resolvedUrl = path;

      // Handle gs:// URLs explicitly by converting them to HTTP download URLs
      if (path.startsWith('gs://')) {
        try {
          resolvedUrl = await FirebaseStorage.instance.refFromURL(path).getDownloadURL();
        } catch (e) {
          return null;
        }
      }

      String cacheKey = resolvedUrl.startsWith('http')
          ? 'pdf_img_'
          : '';
      String? resolvedPath = resolvedUrl.startsWith('http')
          ? await ImageCacheService.cacheImage(
              pathOrUrl: resolvedUrl,
              cacheKey: cacheKey,
            )
          : resolvedUrl;

      if (resolvedPath != null) {
        if (resolvedPath.startsWith('http')) {
          final response = await http
              .get(Uri.parse(resolvedPath))
              .timeout(const Duration(seconds: 5));
          if (response.statusCode == 200) {
            _imageCache[path] = response.bodyBytes;
            return response.bodyBytes;
          }
        } else {
          final file = File(resolvedPath);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            _imageCache[path] = bytes;
            return bytes;
          }
        }
      }
    } catch (_) {}
    return null;
  }"""

content = re.sub(fetch_pattern, new_fetch, content)

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'w', encoding='utf-8') as f:
    f.write(content)
