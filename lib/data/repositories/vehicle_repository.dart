import 'package:image_picker/image_picker.dart';
import '../models/vehicle_model.dart';
import '../services/firestore_service.dart';
import '../services/cloudinary_service.dart';  // ← CHANGÉ
import '../services/alert_checker_service.dart';
import '../../core/utils/result.dart';

class VehicleRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final CloudinaryService _cloudinaryService = CloudinaryService();  // ← CHANGÉ
  final AlertCheckerService _alertChecker = AlertCheckerService();

  Future<Result<String>> createVehicle({
    required VehicleModel vehicle,
    required List<XFile> images,
  }) async {
    try {
      print('🚀 Début création véhicule');

      // 1. Créer le véhicule d'abord (Firebase Firestore)
      final vehicleId = await _firestoreService.createVehicle(vehicle);
      print('✅ Véhicule créé dans Firestore: $vehicleId');

      // 2. Upload des images (Cloudinary)
      List<String> imageUrls = [];
      if (images.isNotEmpty) {
        print('📤 Upload vers Cloudinary...');
        imageUrls = await _cloudinaryService.uploadVehicleImages(  // ← CHANGÉ
          vehicleId: vehicleId,
          imageFiles: images,
        );
        print('✅ ${imageUrls.length} images uploadées sur Cloudinary');

        // 3. Mettre à jour Firestore avec les URLs Cloudinary
        await _firestoreService.updateVehicle(vehicleId, {
          'imageUrls': imageUrls,
          'thumbnailUrl': imageUrls.isNotEmpty ? imageUrls.first : null,
        });
        print('✅ URLs sauvegardées dans Firestore');
      }

      // 4. Véhicule complet
      final updatedVehicle = vehicle.copyWith(
        id: vehicleId,
        imageUrls: imageUrls,
        thumbnailUrl: imageUrls.isNotEmpty ? imageUrls.first : null,
      );

      // 5. Vérifier les alertes
      print('🔔 Vérification des alertes...');
      await _alertChecker.checkAlertsForVehicle(updatedVehicle);
      print('✅ Alertes vérifiées');

      return Result.success(vehicleId);
    } catch (e) {
      print('❌ Erreur: $e');
      return Result.failure('Erreur lors de la création: $e');
    }
  }

  Future<Result<VehicleModel>> getVehicleById(String vehicleId) async {
    try {
      final vehicle = await _firestoreService.getVehicleById(vehicleId);

      if (vehicle == null) {
        return Result.failure('Véhicule non trouvé');
      }

      await _firestoreService.incrementViewCount(vehicleId);
      return Result.success(vehicle);
    } catch (e) {
      return Result.failure('Erreur: $e');
    }
  }

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
    return _firestoreService.getVehicles(
      brand: brand,
      minYear: minYear,
      maxYear: maxYear,
      minPrice: minPrice,
      maxPrice: maxPrice,
      status: status,
      city: city,
      limit: limit,
    );
  }

  Stream<List<VehicleModel>> getSellerVehicles(String sellerId) {
    return _firestoreService.getVehiclesBySeller(sellerId);
  }

  Future<Result<void>> updateVehicle({
    required String vehicleId,
    required Map<String, dynamic> updates,
    List<XFile>? newImages,
  }) async {
    try {
      if (newImages != null && newImages.isNotEmpty) {
        final imageUrls = await _cloudinaryService.uploadVehicleImages(  // ← CHANGÉ
          vehicleId: vehicleId,
          imageFiles: newImages,
        );
        updates['imageUrls'] = imageUrls;
        updates['thumbnailUrl'] = imageUrls.first;
      }

      await _firestoreService.updateVehicle(vehicleId, updates);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Erreur: $e');
    }
  }

  Future<Result<void>> deleteVehicle(String vehicleId) async {
    try {
      // Note: Suppression manuelle des images Cloudinary (optionnel)
      await _firestoreService.deleteVehicle(vehicleId);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Erreur: $e');
    }
  }

  Future<Result<void>> updateVehicleStatus({
    required String vehicleId,
    required VehicleStatus newStatus,
  }) async {
    try {
      await _firestoreService.updateVehicle(vehicleId, {
        'status': newStatus.name,
      });
      return Result.success(null);
    } catch (e) {
      return Result.failure('Erreur: $e');
    }
  }

  Future<Result<void>> markAsSold(String vehicleId) async {
    return updateVehicleStatus(
      vehicleId: vehicleId,
      newStatus: VehicleStatus.sold,
    );
  }

  Future<Result<void>> reactivateVehicle(String vehicleId) async {
    return updateVehicleStatus(
      vehicleId: vehicleId,
      newStatus: VehicleStatus.available,
    );
  }

  Future<Result<List<VehicleModel>>> searchVehicles(String searchTerm) async {
    try {
      final results = await _firestoreService.searchVehicles(searchTerm);
      return Result.success(results);
    } catch (e) {
      return Result.failure('Erreur: $e');
    }
  }
}
