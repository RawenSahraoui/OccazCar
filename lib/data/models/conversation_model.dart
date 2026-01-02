import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String id;
  final String vehicleId;
  final String vehicleTitle; // "Marque Modèle Année"
  final String vehicleThumbnail;
  
  final String buyerId;
  final String buyerName;
  final String? buyerPhotoUrl;
  
  final String sellerId;
  final String sellerName;
  final String? sellerPhotoUrl;
  
  final String lastMessage;
  final DateTime lastMessageAt;
  
  final int unreadCountBuyer;
  final int unreadCountSeller;
  
  final DateTime createdAt;
  final bool isActive;

  ConversationModel({
    required this.id,
    required this.vehicleId,
    required this.vehicleTitle,
    required this.vehicleThumbnail,
    required this.buyerId,
    required this.buyerName,
    this.buyerPhotoUrl,
    required this.sellerId,
    required this.sellerName,
    this.sellerPhotoUrl,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCountBuyer = 0,
    this.unreadCountSeller = 0,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'vehicleTitle': vehicleTitle,
      'vehicleThumbnail': vehicleThumbnail,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerPhotoUrl': buyerPhotoUrl,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerPhotoUrl': sellerPhotoUrl,
      'lastMessage': lastMessage,
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'unreadCountBuyer': unreadCountBuyer,
      'unreadCountSeller': unreadCountSeller,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id: map['id'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      vehicleTitle: map['vehicleTitle'] ?? '',
      vehicleThumbnail: map['vehicleThumbnail'] ?? '',
      buyerId: map['buyerId'] ?? '',
      buyerName: map['buyerName'] ?? '',
      buyerPhotoUrl: map['buyerPhotoUrl'],
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      sellerPhotoUrl: map['sellerPhotoUrl'],
      lastMessage: map['lastMessage'] ?? '',
      lastMessageAt: (map['lastMessageAt'] as Timestamp).toDate(),
      unreadCountBuyer: map['unreadCountBuyer'] ?? 0,
      unreadCountSeller: map['unreadCountSeller'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
    );
  }

  ConversationModel copyWith({
    String? id,
    String? vehicleId,
    String? vehicleTitle,
    String? vehicleThumbnail,
    String? buyerId,
    String? buyerName,
    String? buyerPhotoUrl,
    String? sellerId,
    String? sellerName,
    String? sellerPhotoUrl,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCountBuyer,
    int? unreadCountSeller,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleTitle: vehicleTitle ?? this.vehicleTitle,
      vehicleThumbnail: vehicleThumbnail ?? this.vehicleThumbnail,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      buyerPhotoUrl: buyerPhotoUrl ?? this.buyerPhotoUrl,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerPhotoUrl: sellerPhotoUrl ?? this.sellerPhotoUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCountBuyer: unreadCountBuyer ?? this.unreadCountBuyer,
      unreadCountSeller: unreadCountSeller ?? this.unreadCountSeller,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}