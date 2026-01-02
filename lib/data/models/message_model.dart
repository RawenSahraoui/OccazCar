import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, offer }

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String vehicleId;
  
  final MessageType type;
  final String content;
  final String? imageUrl;
  final double? offerAmount;
  
  final DateTime sentAt;
  final bool isRead;
  final DateTime? readAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.vehicleId,
    required this.type,
    required this.content,
    this.imageUrl,
    this.offerAmount,
    required this.sentAt,
    this.isRead = false,
    this.readAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'vehicleId': vehicleId,
      'type': type.name,
      'content': content,
      'imageUrl': imageUrl,
      'offerAmount': offerAmount,
      'sentAt': Timestamp.fromDate(sentAt),
      'isRead': isRead,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      conversationId: map['conversationId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      offerAmount: map['offerAmount']?.toDouble(),
      sentAt: (map['sentAt'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      readAt: map['readAt'] != null ? (map['readAt'] as Timestamp).toDate() : null,
    );
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? receiverName,
    String? vehicleId,
    MessageType? type,
    String? content,
    String? imageUrl,
    double? offerAmount,
    DateTime? sentAt,
    bool? isRead,
    DateTime? readAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      offerAmount: offerAmount ?? this.offerAmount,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }
}