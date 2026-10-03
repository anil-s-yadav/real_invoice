import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../domain/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseMessaging _messaging;

  NotificationRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseMessaging? messaging,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _messaging = messaging ?? FirebaseMessaging.instance;

  CollectionReference<Map<String, dynamic>> _getNotificationsRef() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications');
  }

  Stream<List<AppNotification>> getNotificationsStream() {
    try {
      return _getNotificationsRef()
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return AppNotification.fromMap(doc.data(), doc.id);
        }).toList();
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _getNotificationsRef().doc(notificationId).update({'isRead': true});
    } catch (e) {
      // Ignore
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final unreadDocs = await _getNotificationsRef()
          .where('isRead', isEqualTo: false)
          .get();
      
      final batch = _firestore.batch();
      for (var doc in unreadDocs.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      // Ignore
    }
  }

  Future<void> setupFCMToken() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      // Request permission
      await _messaging.requestPermission();
      
      // Get the token
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token, userId);
      }

      // Listen to token refreshes
      _messaging.onTokenRefresh.listen((newToken) {
        _saveTokenToFirestore(newToken, userId);
      });
    } catch (e) {
      // Ignore
    }
  }

  Future<void> _saveTokenToFirestore(String token, String userId) async {
    await _firestore.collection('users').doc(userId).set({
      'fcmToken': token,
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
