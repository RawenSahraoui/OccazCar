import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle_model.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //  VÉHICULES

  // Créer un véhicule
  Future<String> createVehicle(VehicleModel vehicle) async {
    try {
      final docRef = await _firestore.collection('vehicles').add(vehicle.toMap());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la création du véhicule: $e');
    }
  }

  // Récupérer un véhicule par ID
  Future<VehicleModel?> getVehicleById(String vehicleId) async {
    try {
      final doc = await _firestore.collection('vehicles').doc(vehicleId).get();
      if (!doc.exists) return null;
      return VehicleModel.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du véhicule: $e');
    }
  }

  // Récupérer tous les véhicules (avec filtres optionnels)
  Stream<List<VehicleModel>> getVehicles({
    String? brand,
    int? minYear,
    int? maxYear,
    double? minPrice,
    double? maxPrice,
    VehicleStatus? status,
    String? city,
    int limit = 20,
  }) {
    try {
      Query query = _firestore.collection('vehicles');

      // Filtre de statut (toujours appliqué)
      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      // Autres filtres
      if (brand != null) query = query.where('brand', isEqualTo: brand);
      if (city != null) query = query.where('city', isEqualTo: city);


      return query.snapshots().map((snapshot) {
        // Récupérer tous les véhicules
        var vehicles = snapshot.docs
            .map((doc) => VehicleModel.fromMap(doc.data() as Map<String, dynamic>))
            .where((vehicle) {
              // Filtres additionnels en mémoire
              if (minYear != null && vehicle.year < minYear) return false;
              if (maxYear != null && vehicle.year > maxYear) return false;
              if (minPrice != null && vehicle.price < minPrice) return false;
              if (maxPrice != null && vehicle.price > maxPrice) return false;
              return true;
            })
            .toList();
        
        // Trier par date de création (plus récent en premier)
        vehicles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        // Limiter le nombre de résultats
        if (vehicles.length > limit) {
          return vehicles.sublist(0, limit);
        }
        
        return vehicles;
      });
    } catch (e) {
      print('Error in getVehicles: $e');
      throw Exception('Erreur lors de la récupération des véhicules: $e');
    }
  }

  // Récupérer les véhicules d'un vendeur
  Stream<List<VehicleModel>> getVehiclesBySeller(String sellerId) {
    try {
      return _firestore
          .collection('vehicles')
          .where('sellerId', isEqualTo: sellerId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => VehicleModel.fromMap(doc.data()))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      });
    } catch (e) {
      print('Error in getVehiclesBySeller: $e');
      throw Exception('Erreur lors de la récupération des véhicules: $e');
    }
  }

  // Mettre à jour un véhicule
  Future<void> updateVehicle(String vehicleId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestore.collection('vehicles').doc(vehicleId).update(updates);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du véhicule: $e');
    }
  }

  // Supprimer un véhicule
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await _firestore.collection('vehicles').doc(vehicleId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du véhicule: $e');
    }
  }

  // Incrémenter le nombre de vues
  Future<void> incrementViewCount(String vehicleId) async {
    try {
      await _firestore.collection('vehicles').doc(vehicleId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'incrémentation des vues: $e');
    }
  }

  // Rechercher des véhicules
  Future<List<VehicleModel>> searchVehicles(String searchTerm) async {
    try {
      // Recherche par marque ou modèle
      final brandQuery = await _firestore
          .collection('vehicles')
          .where('brand', isGreaterThanOrEqualTo: searchTerm)
          .where('brand', isLessThanOrEqualTo: '$searchTerm\uf8ff')
          .limit(10)
          .get();

      final modelQuery = await _firestore
          .collection('vehicles')
          .where('model', isGreaterThanOrEqualTo: searchTerm)
          .where('model', isLessThanOrEqualTo: '$searchTerm\uf8ff')
          .limit(10)
          .get();

      final results = <VehicleModel>[];
      final seenIds = <String>{};

      for (var doc in [...brandQuery.docs, ...modelQuery.docs]) {
        if (!seenIds.contains(doc.id)) {
          results.add(VehicleModel.fromMap(doc.data()));
          seenIds.add(doc.id);
        }
      }

      return results;
    } catch (e) {
      throw Exception('Erreur lors de la recherche: $e');
    }
  }

  //  CONVERSATIONS

  // Créer ou récupérer une conversation
  Future<String> createOrGetConversation({
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
      // Vérifier si une conversation existe déjà
      final existingConv = await _firestore
          .collection('conversations')
          .where('vehicleId', isEqualTo: vehicleId)
          .where('buyerId', isEqualTo: buyerId)
          .where('sellerId', isEqualTo: sellerId)
          .limit(1)
          .get();

      if (existingConv.docs.isNotEmpty) {
        return existingConv.docs.first.id;
      }

      // Créer une nouvelle conversation
      final conversation = ConversationModel(
        id: '',
        vehicleId: vehicleId,
        vehicleTitle: vehicleTitle,
        vehicleThumbnail: vehicleThumbnail,
        buyerId: buyerId,
        buyerName: buyerName,
        buyerPhotoUrl: buyerPhotoUrl,
        sellerId: sellerId,
        sellerName: sellerName,
        sellerPhotoUrl: sellerPhotoUrl,
        lastMessage: 'Conversation démarrée',
        lastMessageAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore.collection('conversations').add(conversation.toMap());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la création de la conversation: $e');
    }
  }

  // Récupérer les conversations d'un utilisateur
  Stream<List<ConversationModel>> getUserConversations(String userId) {
    try {
      // Solution sans orderBy pour éviter le besoin d'index
      return _firestore
          .collection('conversations')
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        // Filtrer et trier en mémoire
        final conversations = snapshot.docs
            .map((doc) => ConversationModel.fromMap(doc.data()))
            .where((conv) => conv.buyerId == userId || conv.sellerId == userId)
            .toList();
        
        // Trier par date en mémoire
        conversations.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
        
        return conversations;
      });
    } catch (e) {
      print('Error in getUserConversations: $e');
      throw Exception('Erreur lors de la récupération des conversations: $e');
    }
  }

  //  MESSAGES

  // Envoyer un message
  Future<void> sendMessage(MessageModel message) async {
    try {
      // Ajouter le message
      await _firestore.collection('messages').add(message.toMap());

      // Récupérer la conversation pour savoir qui est buyer/seller
      final convDoc = await _firestore.collection('conversations').doc(message.conversationId).get();
      final conv = ConversationModel.fromMap(convDoc.data()!);
      
      // Déterminer qui envoie : buyer ou seller
      final isFromBuyer = message.senderId == conv.buyerId;
      
      // Mettre à jour la conversation
      await _firestore.collection('conversations').doc(message.conversationId).update({
        'lastMessage': message.content,
        'lastMessageAt': Timestamp.fromDate(message.sentAt),
        if (isFromBuyer)
          'unreadCountSeller': FieldValue.increment(1)
        else
          'unreadCountBuyer': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error in sendMessage: $e');
      throw Exception('Erreur lors de l\'envoi du message: $e');
    }
  }

  // Récupérer les messages d'une conversation
  Stream<List<MessageModel>> getMessages(String conversationId) {
    try {
      return _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .snapshots()
          .map((snapshot) {
        // Récupérer et trier en mémoire
        final messages = snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data()))
            .toList();
        
        // Trier par date (plus récent en premier)
        messages.sort((a, b) => b.sentAt.compareTo(a.sentAt));
        
        // Limiter à 50 messages
        if (messages.length > 50) {
          return messages.sublist(0, 50);
        }
        
        return messages;
      });
    } catch (e) {
      print('Error in getMessages: $e');
      throw Exception('Erreur lors de la récupération des messages: $e');
    }
  }

  // Marquer les messages comme lus
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    try {
      final messages = await _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': Timestamp.fromDate(DateTime.now()),
        });
      }
      await batch.commit();

      // Réinitialiser le compteur de non-lus dans la conversation
      final conv = await _firestore.collection('conversations').doc(conversationId).get();
      final convData = ConversationModel.fromMap(conv.data()!);
      
      if (convData.buyerId == userId) {
        await conv.reference.update({'unreadCountBuyer': 0});
      } else {
        await conv.reference.update({'unreadCountSeller': 0});
      }
    } catch (e) {
      throw Exception('Erreur lors du marquage des messages: $e');
    }
  }
}