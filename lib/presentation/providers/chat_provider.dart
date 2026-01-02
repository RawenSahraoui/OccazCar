import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/chat_repository.dart';

// Repository provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

// Provider pour les conversations d'un utilisateur
final userConversationsProvider = StreamProvider.family<List<ConversationModel>, String>(
  (ref, userId) {
    final repository = ref.watch(chatRepositoryProvider);
    return repository.getUserConversations(userId);
  },
);

// Provider pour les messages d'une conversation
final conversationMessagesProvider = StreamProvider.family<List<MessageModel>, String>(
  (ref, conversationId) {
    final repository = ref.watch(chatRepositoryProvider);
    return repository.getMessages(conversationId);
  },
);

// Provider pour le nombre total de messages non lus
final totalUnreadCountProvider = StreamProvider.family<int, String>(
  (ref, userId) {
    final repository = ref.watch(chatRepositoryProvider);
    return repository.getTotalUnreadCount(userId);
  },
);

// Provider pour créer/récupérer une conversation
final createConversationProvider = StateNotifierProvider<CreateConversationNotifier, AsyncValue<String?>>((ref) {
  return CreateConversationNotifier(ref.watch(chatRepositoryProvider));
});

class CreateConversationNotifier extends StateNotifier<AsyncValue<String?>> {
  final ChatRepository _repository;

  CreateConversationNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<String?> createOrGetConversation({
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
    state = const AsyncValue.loading();

    final result = await _repository.createOrGetConversation(
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

    if (result.isSuccess) {
      state = AsyncValue.data(result.data);
      return result.data;
    } else {
      state = AsyncValue.error(result.error!, StackTrace.current);
      return null;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

// Provider pour envoyer un message texte
final sendTextMessageProvider = StateNotifierProvider<SendTextMessageNotifier, AsyncValue<void>>((ref) {
  return SendTextMessageNotifier(ref.watch(chatRepositoryProvider));
});

class SendTextMessageNotifier extends StateNotifier<AsyncValue<void>> {
  final ChatRepository _repository;

  SendTextMessageNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String vehicleId,
    required String content,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repository.sendTextMessage(
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      receiverName: receiverName,
      vehicleId: vehicleId,
      content: content,
    );

    if (result.isSuccess) {
      state = const AsyncValue.data(null);
      return true;
    } else {
      state = AsyncValue.error(result.error!, StackTrace.current);
      return false;
    }
  }
}

// Provider pour envoyer une image
final sendImageMessageProvider = StateNotifierProvider<SendImageMessageNotifier, AsyncValue<void>>((ref) {
  return SendImageMessageNotifier(ref.watch(chatRepositoryProvider));
});

class SendImageMessageNotifier extends StateNotifier<AsyncValue<void>> {
  final ChatRepository _repository;

  SendImageMessageNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> sendImage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String vehicleId,
    required XFile imageFile,
    String? caption,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repository.sendImageMessage(
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      receiverName: receiverName,
      vehicleId: vehicleId,
      imageFile: imageFile,
      caption: caption,
    );

    if (result.isSuccess) {
      state = const AsyncValue.data(null);
      return true;
    } else {
      state = AsyncValue.error(result.error!, StackTrace.current);
      return false;
    }
  }
}

// Provider pour envoyer une offre
final sendOfferMessageProvider = StateNotifierProvider<SendOfferMessageNotifier, AsyncValue<void>>((ref) {
  return SendOfferMessageNotifier(ref.watch(chatRepositoryProvider));
});

class SendOfferMessageNotifier extends StateNotifier<AsyncValue<void>> {
  final ChatRepository _repository;

  SendOfferMessageNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> sendOffer({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String vehicleId,
    required double offerAmount,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repository.sendOfferMessage(
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      receiverName: receiverName,
      vehicleId: vehicleId,
      offerAmount: offerAmount,
    );

    if (result.isSuccess) {
      state = const AsyncValue.data(null);
      return true;
    } else {
      state = AsyncValue.error(result.error!, StackTrace.current);
      return false;
    }
  }
}

// Provider pour marquer les messages comme lus
final markMessagesAsReadProvider = Provider<Future<void> Function(String, String)>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return (conversationId, userId) async {
    await repository.markMessagesAsRead(conversationId, userId);
  };
});