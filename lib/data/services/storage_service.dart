import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  Future<String> uploadVehicleImage({
    required String vehicleId,
    required XFile imageFile,
  }) async {
    try {
      final String fileName = '${_uuid.v4()}.jpg';
      final String path = 'vehicles/$vehicleId/$fileName';

      print('📤 Upload image: $path');

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

      // ✅ AJOUT: Attendre avec timeout de 60 secondes
      final TaskSnapshot snapshot = await uploadTask.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Upload timeout - verifiez votre connexion');
        },
      );

      // ✅ Vérifier l'état
      if (snapshot.state != TaskState.success) {
        throw Exception('Upload échoué: ${snapshot.state}');
      }

      final String downloadUrl = await snapshot.ref.getDownloadURL();

      print('✅ Image uploadee: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('❌ Firebase Error: ${e.code} - ${e.message}');
      throw Exception('Erreur Firebase Storage: ${e.message}');
    } catch (e) {
      print('❌ Erreur upload image: $e');
      throw Exception('Erreur lors de l\'upload: $e');
    }
  }

  Future<List<String>> uploadVehicleImages({
    required String vehicleId,
    required List<XFile> imageFiles,
  }) async {
    try {
      print('📤 Upload de ${imageFiles.length} images pour vehicule $vehicleId');
      final List<String> downloadUrls = [];

      for (int i = 0; i < imageFiles.length; i++) {
        print('📤 Upload image ${i + 1}/${imageFiles.length}');

        try {
          final url = await uploadVehicleImage(
            vehicleId: vehicleId,
            imageFile: imageFiles[i],
          );
          downloadUrls.add(url);
          print('✅ Image ${i + 1} uploadee: $url');
        } catch (e) {
          print('⚠️ Erreur image ${i + 1}, on continue...');
          // Continue avec les autres images même si une échoue
        }
      }

      if (downloadUrls.isEmpty) {
        throw Exception('Aucune image n\'a pu être uploadée');
      }

      print('✅ TOTAL: ${downloadUrls.length} images uploadees');
      return downloadUrls;
    } catch (e) {
      print('❌ Erreur upload images: $e');
      throw Exception('Erreur lors de l\'upload des images: $e');
    }
  }

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

      final TaskSnapshot snapshot = await uploadTask.timeout(
        const Duration(seconds: 30),
      );

      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image de profil: $e');
    }
  }

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

      final TaskSnapshot snapshot = await uploadTask.timeout(
        const Duration(seconds: 30),
      );

      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'image: $e');
    }
  }

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