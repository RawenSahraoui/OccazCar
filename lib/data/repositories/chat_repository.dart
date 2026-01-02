import 'package:image_picker/image_picker.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import 'auth_repository.dart';
import 'package:uuid/uuid.dart';

class ChatRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final Uuid _uuid = const Uuid();

  // Créer ou récupérer une conversation
  Future<Result<String>> createOrGetConversation({
    required String vehicleId,
    required String buyerId,
    required String sellerId,
    required String vehicleTitle,
    required String vehicleThumbnail,
    required String buyerName,
    required String sellerName,
    String? buyerPhotoUrl,
    String? sellerPhotoUrl,
  }) async {
    try {
      final conversationId = await _firestoreService.createOrGetConversation(
        vehicleId: vehicleId,
        buyerId: buyerId,
        sellerId: sellerId,
        vehicleTitle: vehicleTitle,
        vehicleThumbnail: vehicleThumbnail,
        buyerName: buyerName,
        sellerName: sellerName,
        buyerPhotoUrl: buyerPhotoUrl,
        sellerPhotoUrl: sellerPhotoUrl,
      );

      return Result.success(conversationId);
    } catch (e) {
      return Result.error('Erreur lors de la création de la conversation: $e');
    }
  }

  // Récupérer les conversations d'un utilisateur
  Stream<List<ConversationModel>> getUserConversations(String userId) {
    return _firestoreService.getUserConversations(userId);
  }

  // Envoyer un message texte
  Future<Result<void>> sendTextMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String vehicleId,
    required String content,
  }) async {
    try {
      final message = MessageModel(
        id: _uuid.v4(),
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        receiverId: receiverId,
        receiverName: receiverName,
        vehicleId: vehicleId,
        type: MessageType.text,
        content: content,
        sentAt: DateTime.now(),
      );

      await _firestoreService.sendMessage(message);
      return Result.success(null);
    } catch (e) {
      return Result.error('Erreur lors de l\'envoi du message: $e');
    }
  }

  // Envoyer une image
  Future<Result<void>> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String vehicleId,
    required XFile imageFile,
    String? caption,
  }) async {
    try {
      // Upload l'image
      final imageUrl = await _storageService.uploadChatImage(
        conversationId: conversationId,
        imageFile: imageFile,
      );

      final message = MessageModel(
        id: _uuid.v4(),
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        receiverId: receiverId,
        receiverName: receiverName,
        vehicleId: vehicleId,
        type: MessageType.image,
        content: caption ?? 'Image',
        imageUrl: imageUrl,
        sentAt: DateTime.now(),
      );

      await _firestoreService.sendMessage(message);
      return Result.success(null);
    } catch (e) {
      return Result.error('Erreur lors de l\'envoi de l\'image: $e');
    }
  }

  // Envoyer une offre de prix
  Future<Result<void>> sendOfferMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String vehicleId,
    required double offerAmount,
  }) async {
    try {
      final message = MessageModel(
        id: _uuid.v4(),
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        receiverId: receiverId,
        receiverName: receiverName,
        vehicleId: vehicleId,
        type: MessageType.offer,
        content: 'Offre de prix: ${offerAmount.toStringAsFixed(2)} TND',
        offerAmount: offerAmount,
        sentAt: DateTime.now(),
      );

      await _firestoreService.sendMessage(message);
      return Result.success(null);
    } catch (e) {
      return Result.error('Erreur lors de l\'envoi de l\'offre: $e');
    }
  }

  // Récupérer les messages d'une conversation
  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _firestoreService.getMessages(conversationId);
  }

  // Marquer les messages comme lus
  Future<Result<void>> markMessagesAsRead(String conversationId, String userId) async {
    try {
      await _firestoreService.markMessagesAsRead(conversationId, userId);
      return Result.success(null);
    } catch (e) {
      return Result.error('Erreur lors du marquage des messages: $e');
    }
  }

  // Compter les messages non lus total pour un utilisateur
  Stream<int> getTotalUnreadCount(String userId) {
    return _firestoreService.getUserConversations(userId).map((conversations) {
      int total = 0;
      for (var conv in conversations) {
        if (conv.buyerId == userId) {
          total += conv.unreadCountBuyer;
        } else {
          total += conv.unreadCountSeller;
        }
      }
      return total;
    });
  }
}