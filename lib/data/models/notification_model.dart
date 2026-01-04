import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String vehicleId;
  final String alertId;
  final String alertTitle;
  final String vehicleTitle;
  final String vehicleBrand;
  final String vehicleModel;
  final double vehiclePrice;
  final int vehicleYear;
  final String? vehicleImageUrl;
  final String vehicleCity;
  final DateTime createdAt;
  final bool read;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.alertId,
    required this.alertTitle,
    required this.vehicleTitle,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.vehiclePrice,
    required this.vehicleYear,
    this.vehicleImageUrl,
    required this.vehicleCity,
    required this.createdAt,
    this.read = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'vehicleId': vehicleId,
      'alertId': alertId,
      'alertTitle': alertTitle,
      'vehicleTitle': vehicleTitle,
      'vehicleBrand': vehicleBrand,
      'vehicleModel': vehicleModel,
      'vehiclePrice': vehiclePrice,
      'vehicleYear': vehicleYear,
      'vehicleImageUrl': vehicleImageUrl,
      'vehicleCity': vehicleCity,
      'createdAt': Timestamp.fromDate(createdAt),
      'read': read,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      userId: map['userId'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      alertId: map['alertId'] ?? '',
      alertTitle: map['alertTitle'] ?? '',
      vehicleTitle: map['vehicleTitle'] ?? '',
      vehicleBrand: map['vehicleBrand'] ?? '',
      vehicleModel: map['vehicleModel'] ?? '',
      vehiclePrice: (map['vehiclePrice'] ?? 0).toDouble(),
      vehicleYear: map['vehicleYear'] ?? 0,
      vehicleImageUrl: map['vehicleImageUrl'],
      vehicleCity: map['vehicleCity'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      read: map['read'] ?? false,
    );
  }
}