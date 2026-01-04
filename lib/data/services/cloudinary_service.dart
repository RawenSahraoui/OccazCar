import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CloudinaryService {
  late final CloudinaryPublic _cloudinary;

  CloudinaryService() {
    _cloudinary = CloudinaryPublic('draaepcsn', 'occazcar', cache: false);
  }

  /// Upload une seule image
  Future<String> uploadVehicleImage({
    required String vehicleId,
    required XFile imageFile,
  }) async {
    try {
      print('📤 Upload image vers Cloudinary...');

      CloudinaryResponse response;

      if (kIsWeb) {
        // Web: upload depuis bytes
        final bytes = await imageFile.readAsBytes();
        response = await _cloudinary.uploadFile(
          CloudinaryFile.fromBytesData(
            bytes,
            identifier: imageFile.name,
            folder: 'vehicles/$vehicleId',
            resourceType: CloudinaryResourceType.Image,
          ),
        );
      } else {
        // Mobile: upload depuis path
        response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            imageFile.path,
            folder: 'vehicles/$vehicleId',
            resourceType: CloudinaryResourceType.Image,
          ),
        );
      }

      print('✅ Image uploadée: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      print('❌ Erreur upload Cloudinary: $e');
      throw Exception('Erreur upload: $e');
    }
  }

  /// Upload plusieurs images
  Future<List<String>> uploadVehicleImages({
    required String vehicleId,
    required List<XFile> imageFiles,
  }) async {
    try {
      print('📤 Upload de ${imageFiles.length} images...');
      final List<String> urls = [];

      for (int i = 0; i < imageFiles.length; i++) {
        print('📤 Upload image ${i + 1}/${imageFiles.length}');

        try {
          final url = await uploadVehicleImage(
            vehicleId: vehicleId,
            imageFile: imageFiles[i],
          );
          urls.add(url);
          print('✅ Image ${i + 1} uploadée');
        } catch (e) {
          print('⚠️ Erreur image ${i + 1}: $e');
          // Continue avec les autres images
        }
      }

      if (urls.isEmpty) {
        throw Exception('Aucune image uploadée');
      }

      print('✅ Total: ${urls.length} images uploadées');
      return urls;
    } catch (e) {
      print('❌ Erreur: $e');
      throw Exception('Erreur upload images: $e');
    }
  }

  /// Upload image de profil
  Future<String> uploadProfileImage({
    required String userId,
    required XFile imageFile,
  }) async {
    try {
      CloudinaryResponse response;

      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        response = await _cloudinary.uploadFile(
          CloudinaryFile.fromBytesData(
            bytes,
            identifier: 'profile_$userId',
            folder: 'users/$userId',
            resourceType: CloudinaryResourceType.Image,
          ),
        );
      } else {
        response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            imageFile.path,
            folder: 'users/$userId',
            resourceType: CloudinaryResourceType.Image,
          ),
        );
      }

      return response.secureUrl;
    } catch (e) {
      throw Exception('Erreur upload profil: $e');
    }
  }

  /// Upload image de chat
  Future<String> uploadChatImage({
    required String conversationId,
    required XFile imageFile,
  }) async {
    try {
      CloudinaryResponse response;

      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        response = await _cloudinary.uploadFile(
          CloudinaryFile.fromBytesData(
            bytes,
            identifier: imageFile.name,
            folder: 'chats/$conversationId',
            resourceType: CloudinaryResourceType.Image,
          ),
        );
      } else {
        response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            imageFile.path,
            folder: 'chats/$conversationId',
            resourceType: CloudinaryResourceType.Image,
          ),
        );
      }

      return response.secureUrl;
    } catch (e) {
      throw Exception('Erreur upload chat: $e');
    }
  }

  /// Note: La suppression nécessite l'API avec authentification
  /// Pour le gratuit, on peut simplement ne pas supprimer ou le faire manuellement
  Future<void> deleteImage(String publicId) async {
    // Nécessite API Key et Secret (pas en gratuit unsigned)
    print('⚠️ Suppression manuelle requise sur Cloudinary dashboard');
  }

  Future<void> deleteVehicleImages(String vehicleId) async {
    print('⚠️ Suppression manuelle requise sur Cloudinary dashboard');
  }
}