import 'package:image_picker/image_picker.dart';
import '../models/vehicle_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import 'auth_repository.dart';

class VehicleRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  // Créer un véhicule avec images
  Future<Result<String>> createVehicle({
    required VehicleModel vehicle,
    required List<XFile> images,
  }) async {
    try {
      // 1. Créer le véhicule dans Firestore (sans images pour l'instant)
      final vehicleId = await _firestoreService.createVehicle(vehicle);

      // 2. Upload les images
      final imageUrls = await _storageService.uploadVehicleImages(
        vehicleId: vehicleId,
        imageFiles: images,
      );

      // 3. Mettre à jour le véhicule avec les URLs des images
      await _firestoreService.updateVehicle(vehicleId, {
        'imageUrls': imageUrls,
        'thumbnailUrl': imageUrls.isNotEmpty ? imageUrls.first : null,
      });

      return Result.success(vehicleId);
    } catch (e) {
      return Result.error('Erreur lors de la création du véhicule: $e');
    }
  }

  // Récupérer un véhicule par ID
  Future<Result<VehicleModel>> getVehicleById(String vehicleId) async {
    try {
      final vehicle = await _firestoreService.getVehicleById(vehicleId);
      
      if (vehicle == null) {
        return Result.error('Véhicule non trouvé');
      }

      // Incrémenter le compteur de vues
      await _firestoreService.incrementViewCount(vehicleId);

      return Result.success(vehicle);
    } catch (e) {
      return Result.error('Erreur lors de la récupération du véhicule: $e');
    }
  }

  // Récupérer tous les véhicules (avec filtres)
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

  // Récupérer les véhicules d'un vendeur
  Stream<List<VehicleModel>> getSellerVehicles(String sellerId) {
    return _firestoreService.getVehiclesBySeller(sellerId);
  }

  // Mettre à jour un véhicule
  Future<Result<void>> updateVehicle({
    required String vehicleId,
    required Map<String, dynamic> updates,
    List<XFile>? newImages,
  }) async {
    try {
      // Si de nouvelles images sont fournies, les uploader
      if (newImages != null && newImages.isNotEmpty) {
        final imageUrls = await _storageService.uploadVehicleImages(
          vehicleId: vehicleId,
          imageFiles: newImages,
        );
        
        updates['imageUrls'] = imageUrls;
        updates['thumbnailUrl'] = imageUrls.first;
      }

      await _firestoreService.updateVehicle(vehicleId, updates);
      return Result.success(null);
    } catch (e) {
      return Result.error('Erreur lors de la mise à jour: $e');
    }
  }

  // Supprimer un véhicule
  Future<Result<void>> deleteVehicle(String vehicleId) async {
    try {
      // Supprimer les images
      await _storageService.deleteVehicleImages(vehicleId);
      
      // Supprimer le véhicule
      await _firestoreService.deleteVehicle(vehicleId);
      
      return Result.success(null);
    } catch (e) {
      return Result.error('Erreur lors de la suppression: $e');
    }
  }

  // Changer le statut d'un véhicule
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
      return Result.error('Erreur lors du changement de statut: $e');
    }
  }

  // Rechercher des véhicules
  Future<Result<List<VehicleModel>>> searchVehicles(String searchTerm) async {
    try {
      final results = await _firestoreService.searchVehicles(searchTerm);
      return Result.success(results);
    } catch (e) {
      return Result.error('Erreur lors de la recherche: $e');
    }
  }

  // Marquer un véhicule comme vendu
  Future<Result<void>> markAsSold(String vehicleId) async {
    return updateVehicleStatus(
      vehicleId: vehicleId,
      newStatus: VehicleStatus.sold,
    );
  }

  // Réactiver un véhicule
  Future<Result<void>> reactivateVehicle(String vehicleId) async {
    return updateVehicleStatus(
      vehicleId: vehicleId,
      newStatus: VehicleStatus.available,
    );
  }
}