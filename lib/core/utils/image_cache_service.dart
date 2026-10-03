import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Persistent local image cache.
///
/// Downloads remote images (Firebase Storage URLs) to the app's local
/// documents directory and keeps a URL→localPath mapping in SharedPreferences.
/// Subsequent calls return the cached local path instantly — no network hit.
/// Re-downloads only when the remote URL changes.
class ImageCacheService {
  ImageCacheService._();

  static const String _prefKeyPrefix = 'cached_image_';
  static String? _cacheDir;

  /// Initialise the cache directory (call once at app startup or lazily).
  static Future<String> _getCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/invoz_image_cache');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _cacheDir = dir.path;
    return _cacheDir!;
  }

  /// Given a remote URL (or local path), ensure a local cached copy exists
  /// and return the local file path.
  ///
  /// - If [pathOrUrl] is already a local file, returns it as-is.
  /// - If [pathOrUrl] is a remote URL that was previously cached and the
  ///   URL hasn't changed, returns the cached local path.
  /// - If it's a new or changed URL, downloads and caches it.
  ///
  /// [cacheKey] must be unique per image slot (e.g. `'logo_<profileId>'`).
  static Future<String?> cacheImage({
    required String? pathOrUrl,
    required String cacheKey,
  }) async {
    if (pathOrUrl == null || pathOrUrl.isEmpty) return null;

    // Already a local file — just return it
    if (!pathOrUrl.startsWith('http')) {
      return pathOrUrl;
    }

    final prefs = await SharedPreferences.getInstance();
    final urlKey = '${_prefKeyPrefix}url_$cacheKey';
    final pathKey = '${_prefKeyPrefix}path_$cacheKey';

    final cachedUrl = prefs.getString(urlKey);
    final cachedPath = prefs.getString(pathKey);

    // URL unchanged and local file still exists — return cached path
    if (cachedUrl == pathOrUrl && cachedPath != null) {
      final file = File(cachedPath);
      if (await file.exists()) {
        return cachedPath;
      }
    }

    // Download and cache
    try {
      final response = await http
          .get(Uri.parse(pathOrUrl))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final cacheDir = await _getCacheDir();
        final ext = _extractExtension(pathOrUrl);
        final localPath = '$cacheDir/$cacheKey$ext';
        final file = File(localPath);
        await file.writeAsBytes(response.bodyBytes);

        // Save mapping
        await prefs.setString(urlKey, pathOrUrl);
        await prefs.setString(pathKey, localPath);

        return localPath;
      }
    } catch (e) {
      debugPrint('ImageCacheService: Failed to cache $cacheKey — $e');
    }

    // Fallback: if we have an old cached copy, use it even though URL changed
    if (cachedPath != null) {
      final file = File(cachedPath);
      if (await file.exists()) return cachedPath;
    }

    // Complete fallback — return original URL so the caller can try HTTP
    return pathOrUrl;
  }

  /// Remove a cached image for a given key.
  static Future<void> evict(String cacheKey) async {
    final prefs = await SharedPreferences.getInstance();
    final pathKey = '${_prefKeyPrefix}path_$cacheKey';
    final cachedPath = prefs.getString(pathKey);

    if (cachedPath != null) {
      final file = File(cachedPath);
      if (await file.exists()) {
        await file.delete();
      }
    }

    await prefs.remove('${_prefKeyPrefix}url_$cacheKey');
    await prefs.remove(pathKey);
  }

  /// Clear the entire image cache.
  static Future<void> clearAll() async {
    final cacheDir = await _getCacheDir();
    final dir = Directory(cacheDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      await dir.create(recursive: true);
    }

    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefKeyPrefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  static String _extractExtension(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path.toLowerCase();
      if (path.contains('.png')) return '.png';
      if (path.contains('.jpg') || path.contains('.jpeg')) return '.jpg';
      if (path.contains('.webp')) return '.webp';
    } catch (_) {}
    return '.png'; // default
  }
}
