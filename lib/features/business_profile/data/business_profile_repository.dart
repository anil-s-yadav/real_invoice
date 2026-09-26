import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/business_profile_model.dart';
import 'package:uuid/uuid.dart';

class BusinessProfileRepository {
  static const String _activeProfileKey = 'active_profile_id';

  // Get current user ID, throwing if not authenticated
  String get _userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  // Reference to the user's companies subcollection
  CollectionReference<Map<String, dynamic>> get _companiesRef {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('companies');
  }

  Future<String> getActiveProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeProfileKey) ?? 'default_profile';
  }

  Future<void> setActiveProfileId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeProfileKey, id);
  }

  Future<BusinessProfile> getProfile([String? id]) async {
    if (id != null && id.isEmpty) {
      return const BusinessProfile(id: '');
    }

    final targetId = id ?? await getActiveProfileId();
    
    try {
      final doc = await _companiesRef.doc(targetId).get();
      if (!doc.exists) {
        return BusinessProfile(id: targetId);
      }
      return BusinessProfile.fromMap(doc.data()!);
    } catch (e) {
      print('Error fetching profile: $e');
      return BusinessProfile(id: targetId);
    }
  }

  Future<List<BusinessProfile>> getAllProfiles({bool forceSync = false}) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot;
      try {
        querySnapshot = await _companiesRef.get(GetOptions(source: forceSync ? Source.server : Source.cache));
        if (querySnapshot.docs.isEmpty && !forceSync) {
          querySnapshot = await _companiesRef.get(const GetOptions(source: Source.server));
        }
      } catch (_) {
        querySnapshot = await _companiesRef.get(const GetOptions(source: Source.server));
      }
      return querySnapshot.docs
          .map((doc) => BusinessProfile.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching all profiles: $e');
      return [];
    }
  }

  Future<BusinessProfile> saveProfile(BusinessProfile profile) async {
    final existingProfiles = await getAllProfiles();
    final isFirstProfile = existingProfiles.isEmpty;
    final profileToSaveId = profile.id.isEmpty ? const Uuid().v4() : profile.id;
    
    // Upload assets to Firebase Storage if they are local files
    String? logoPath = profile.logoPath;
    String? signaturePath = profile.signaturePath;
    String? stampPath = profile.stampPath;

    logoPath = await _uploadAssetIfLocal(logoPath, profileToSaveId, 'logo.png');
    signaturePath = await _uploadAssetIfLocal(signaturePath, profileToSaveId, 'signature.png');
    stampPath = await _uploadAssetIfLocal(stampPath, profileToSaveId, 'stamp.png');

    final profileToSave = profile.copyWith(
      id: profileToSaveId,
      logoPath: logoPath,
      signaturePath: signaturePath,
      stampPath: stampPath,
    );

    await _companiesRef.doc(profileToSave.id).set(
      profileToSave.toMap(),
      SetOptions(merge: true),
    );

    if (isFirstProfile) {
      await setActiveProfileId(profileToSave.id);
    }

    return profileToSave;
  }

  Future<String?> _uploadAssetIfLocal(String? pathOrUrl, String companyId, String fileName) async {
    if (pathOrUrl == null || pathOrUrl.isEmpty) return null;
    if (pathOrUrl.startsWith('http')) return pathOrUrl; // Already uploaded

    try {
      final file = File(pathOrUrl);
      if (!await file.exists()) return pathOrUrl;

      final ref = FirebaseStorage.instance
          .ref()
          .child('users/$_userId/companies/$companyId/assets/$fileName');

      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading $fileName: $e');
      return pathOrUrl; // Fallback to local path if upload fails
    }
  }

  Future<void> deleteProfile(String id) async {
    await _companiesRef.doc(id).delete();

    // If we deleted the active profile, reset or auto-activate another one
    final activeId = await getActiveProfileId();
    if (activeId == id || activeId == 'default_profile') {
      final remainingProfiles = await getAllProfiles();
      if (remainingProfiles.isNotEmpty) {
        await setActiveProfileId(remainingProfiles.first.id);
      } else {
        await setActiveProfileId('default_profile');
      }
    } else {
      // Also check if we deleted a profile and now there is only 1 left, maybe we should activate it?
      // Actually, if we deleted a profile and activeId is NOT the deleted one, it means the active profile is still valid.
      // But just to be sure, if there is only 1 profile remaining, it's safe to make it active (it might already be active).
      final remainingProfiles = await getAllProfiles();
      if (remainingProfiles.length == 1) {
        await setActiveProfileId(remainingProfiles.first.id);
      }
    }
  }
}
