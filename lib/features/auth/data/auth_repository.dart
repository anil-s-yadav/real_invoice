import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../domain/auth_user_model.dart';
import '../domain/device_model.dart';

abstract class AuthRepository {
  Stream<AuthUser?> get user;
  Future<AuthUser?> signInWithGoogle();
  Future<AuthUser> signInWithApple();
  Future<void> signOut();
  Future<AuthUser?> getCurrentUser();
  Future<void> registerDevice();
  Future<void> logOutAllDevices();
}

class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  bool _isGoogleSignInInitialized = false;

  FirebaseAuthRepository({
    fb.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _googleSignIn.initialize();
      _isGoogleSignInInitialized = true;
    }
  }

  AuthUser? _mapFirebaseUser(fb.User? fbUser) {
    if (fbUser == null) return null;
    return AuthUser(
      id: fbUser.uid,
      email: fbUser.email,
      displayName: fbUser.displayName,
      photoUrl: fbUser.photoURL,
    );
  }

  @override
  Stream<AuthUser?> get user {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    return _mapFirebaseUser(_firebaseAuth.currentUser);
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();
      final googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );
      final googleAuth = googleUser.authentication;
      final authorization = await googleUser.authorizationClient
          .authorizationForScopes(['email', 'profile']);
      final credential = fb.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: authorization?.accessToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = _mapFirebaseUser(userCredential.user);
      if (user == null) throw Exception('Sign-in failed.');
      return user;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<AuthUser> signInWithApple() async {
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oauthCredential = fb.OAuthProvider(
      'apple.com',
    ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

    final userCredential = await _firebaseAuth.signInWithCredential(
      oauthCredential,
    );

    // Apple only returns name on first sign-in; update profile if available
    final fbUser = userCredential.user;
    if (fbUser != null &&
        (fbUser.displayName == null || fbUser.displayName!.isEmpty)) {
      final fullName = [
        appleCredential.givenName,
        appleCredential.familyName,
      ].where((n) => n != null && n.isNotEmpty).join(' ');
      if (fullName.isNotEmpty) {
        await fbUser.updateDisplayName(fullName);
        await fbUser.reload();
      }
    }

    final user = _mapFirebaseUser(_firebaseAuth.currentUser);
    if (user == null) throw Exception('Sign-in failed.');
    return user;
  }

  @override
  Future<void> signOut() async {
    await _ensureGoogleSignInInitialized();
    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<void> registerDevice() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      // 1. Ensure the parent user document exists
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final userDoc = await userDocRef.get();
      if (!userDoc.exists) {
        await userDocRef.set({
          'email': user.email ?? '',
          'displayName': user.displayName ?? 'Unknown User',
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        }, SetOptions(merge: true));
      }

      // 2. Register the device
      final messaging = FirebaseMessaging.instance;
      String? token;

      // Request permission for iOS (ignored on Android)
      if (!kIsWeb && Platform.isIOS) {
        await messaging.requestPermission();
      }

      token = await messaging.getToken();

      final deviceInfo = DeviceInfoPlugin();
      String deviceModel = 'Unknown Device';
      String platformStr = 'unknown';

      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        deviceModel = webInfo.userAgent ?? 'Web Browser';
        platformStr = 'web';
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceModel = '${androidInfo.brand} ${androidInfo.model}';
        platformStr = 'android';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceModel = iosInfo.name;
        platformStr = 'ios';
      }

      // Generate a stable device ID or just use token as doc ID (but token changes)
      // Better to use a hash of the device name + platform or let Firestore generate it
      // Let's use a combination of platform and model as a simple stable ID for this example
      final deviceId = _sha256ofString(
        deviceModel + platformStr,
      ).substring(0, 16);

      final device = DeviceModel(
        deviceId: deviceId,
        fcmToken: token,
        deviceModel: deviceModel,
        lastActive: DateTime.now(),
        platform: platformStr,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('devices')
          .doc(deviceId)
          .set(device.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      print('Failed to register device: $e');
    }
  }

  @override
  Future<void> logOutAllDevices() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      final devicesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('devices');

      final snapshot = await devicesRef.get();
      final batch = FirebaseFirestore.instance.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // Finally, sign out locally
      await signOut();
    } catch (e) {
      throw Exception('Failed to log out all devices: $e');
    }
  }
}
