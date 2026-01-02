import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Upload une image de véhicule
  Future<String> uploadVehicleImage({
    required String vehicleId,
    required XFile imageFile,
  }) async {
    try {
      final String fileName = '${_uuid.v4()}.jpg';
      final String path = 'vehicles/$vehicleId/$fileName';

      final Reference ref = _storage.ref().child(path);

      UploadTask uploadTask;
      if (kIsWeb) {
        // Pour le web
        final bytes = await imageFile.readAsBytes();
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        // Pour mobile/desktop
        uploadTask = ref.putFile(File(imageFile.path));
      }

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  // Upload plusieurs images de véhicule
  Future<List<String>> uploadVehicleImages({
    required String vehicleId,
    required List<XFile> imageFiles,
  }) async {
    try {
      final List<String> downloadUrls = [];

      for (final imageFile in imageFiles) {
        final url = await uploadVehicleImage(
          vehicleId: vehicleId,
          imageFile: imageFile,
        );
        downloadUrls.add(url);
      }

      return downloadUrls;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload des images: $e');
    }
  }

  // Upload une image de profil utilisateur
  Future<String> uploadProfileImage({
    required String userId,
    required XFile imageFile,
  }) async {
    try {
      final String fileName = 'profile_$userId.jpg';
      final String path = 'users/$userId/$fileName';

      final Reference ref = _storage.ref().child(path);

      UploadTask uploadTask;
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        uploadTask = ref.putFile(File(imageFile.path));
      }

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image de profil: $e');
    }
  }

  // Upload une image dans le chat
  Future<String> uploadChatImage({
    required String conversationId,
    required XFile imageFile,
  }) async {
    try {
      final String fileName = '${_uuid.v4()}.jpg';
      final String path = 'chats/$conversationId/$fileName';

      final Reference ref = _storage.ref().child(path);

      UploadTask uploadTask;
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        uploadTask = ref.putFile(File(imageFile.path));
      }

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  // Supprimer une image
  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'image: $e');
    }
  }

  // Supprimer toutes les images d'un véhicule
  Future<void> deleteVehicleImages(String vehicleId) async {
    try {
      final Reference ref = _storage.ref().child('vehicles/$vehicleId');
      final ListResult result = await ref.listAll();
      
      for (final Reference fileRef in result.items) {
        await fileRef.delete();
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression des images: $e');
    }
  }
}