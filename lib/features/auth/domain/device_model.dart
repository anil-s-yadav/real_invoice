import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceModel {
  final String deviceId;
  final String? fcmToken;
  final String deviceModel;
  final DateTime lastActive;
  final String platform;

  DeviceModel({
    required this.deviceId,
    this.fcmToken,
    required this.deviceModel,
    required this.lastActive,
    required this.platform,
  });

  factory DeviceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return DeviceModel(
      deviceId: doc.id,
      fcmToken: data['fcmToken'] as String?,
      deviceModel: data['deviceModel'] as String? ?? 'Unknown Device',
      lastActive: (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
      platform: data['platform'] as String? ?? 'unknown',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (fcmToken != null) 'fcmToken': fcmToken,
      'deviceModel': deviceModel,
      'lastActive': Timestamp.fromDate(lastActive),
      'platform': platform,
    };
  }
}
