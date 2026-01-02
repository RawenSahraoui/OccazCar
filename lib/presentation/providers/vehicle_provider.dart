import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/vehicle_model.dart';
import '../../data/repositories/vehicle_repository.dart';

// Repository provider
final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepository();
});

// Provider pour tous les véhicules
final vehiclesProvider = StreamProvider.family<List<VehicleModel>, VehicleFilters>(
  (ref, filters) {
    final repository = ref.watch(vehicleRepositoryProvider);
    return repository.getVehicles(
      brand: filters.brand,
      minYear: filters.minYear,
      maxYear: filters.maxYear,
      minPrice: filters.minPrice,
      maxPrice: filters.maxPrice,
      status: filters.status,
      city: filters.city,
      limit: filters.limit,
    );
  },
);

// Classe pour les filtres de recherche
class VehicleFilters {
  final String? brand;
  final int? minYear;
  final int? maxYear;
  final double? minPrice;
  final double? maxPrice;
  final VehicleStatus? status;
  final String? city;
  final int limit;

  VehicleFilters({
    this.brand,
    this.minYear,
    this.maxYear,
    this.minPrice,
    this.maxPrice,
    this.status,
    this.city,
    this.limit = 20,
  });

  VehicleFilters copyWith({
    String? brand,
    int? minYear,
    int? maxYear,
    double? minPrice,
    double? maxPrice,
    VehicleStatus? status,
    String? city,
    int? limit,
  }) {
    return VehicleFilters(
      brand: brand ?? this.brand,
      minYear: minYear ?? this.minYear,
      maxYear: maxYear ?? this.maxYear,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      status: status ?? this.status,
      city: city ?? this.city,
      limit: limit ?? this.limit,
    );
  }
}

// Provider pour les véhicules disponibles
final availableVehiclesProvider = StreamProvider<List<VehicleModel>>((ref) {
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.getVehicles(status: VehicleStatus.available);
});

// Provider pour les véhicules d'un vendeur
final sellerVehiclesProvider = StreamProvider.family<List<VehicleModel>, String>(
  (ref, sellerId) {
    final repository = ref.watch(vehicleRepositoryProvider);
    return repository.getSellerVehicles(sellerId);
  },
);

// Provider pour un véhicule spécifique
final vehicleByIdProvider = FutureProvider.family<VehicleModel?, String>(
  (ref, vehicleId) async {
    final repository = ref.watch(vehicleRepositoryProvider);
    final result = await repository.getVehicleById(vehicleId);
    return result.isSuccess ? result.data : null;
  },
);

// Provider pour créer un véhicule
final createVehicleProvider = StateNotifierProvider<CreateVehicleNotifier, AsyncValue<String?>>((ref) {
  return CreateVehicleNotifier(ref.watch(vehicleRepositoryProvider));
});

class CreateVehicleNotifier extends StateNotifier<AsyncValue<String?>> {
  final VehicleRepository _repository;

  CreateVehicleNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<String?> createVehicle({
    required VehicleModel vehicle,
    required List<XFile> images,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repository.createVehicle(
      vehicle: vehicle,
      images: images,
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

// Provider pour mettre à jour un véhicule
final updateVehicleProvider = StateNotifierProvider<UpdateVehicleNotifier, AsyncValue<void>>((ref) {
  return UpdateVehicleNotifier(ref.watch(vehicleRepositoryProvider));
});

class UpdateVehicleNotifier extends StateNotifier<AsyncValue<void>> {
  final VehicleRepository _repository;

  UpdateVehicleNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> updateVehicle({
    required String vehicleId,
    required Map<String, dynamic> updates,
    List<XFile>? newImages,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repository.updateVehicle(
      vehicleId: vehicleId,
      updates: updates,
      newImages: newImages,
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

// Provider pour supprimer un véhicule
final deleteVehicleProvider = StateNotifierProvider<DeleteVehicleNotifier, AsyncValue<void>>((ref) {
  return DeleteVehicleNotifier(ref.watch(vehicleRepositoryProvider));
});

class DeleteVehicleNotifier extends StateNotifier<AsyncValue<void>> {
  final VehicleRepository _repository;

  DeleteVehicleNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> deleteVehicle(String vehicleId) async {
    state = const AsyncValue.loading();

    final result = await _repository.deleteVehicle(vehicleId);

    if (result.isSuccess) {
      state = const AsyncValue.data(null);
      return true;
    } else {
      state = AsyncValue.error(result.error!, StackTrace.current);
      return false;
    }
  }
}

// Provider pour rechercher des véhicules
final searchVehiclesProvider = StateNotifierProvider<SearchVehiclesNotifier, AsyncValue<List<VehicleModel>>>((ref) {
  return SearchVehiclesNotifier(ref.watch(vehicleRepositoryProvider));
});

class SearchVehiclesNotifier extends StateNotifier<AsyncValue<List<VehicleModel>>> {
  final VehicleRepository _repository;

  SearchVehiclesNotifier(this._repository) : super(const AsyncValue.data([]));

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();

    final result = await _repository.searchVehicles(query);

    if (result.isSuccess) {
      state = AsyncValue.data(result.data ?? []);
    } else {
      state = AsyncValue.error(result.error!, StackTrace.current);
    }
  }

  void clear() {
    state = const AsyncValue.data([]);
  }
}

// Provider pour changer le statut d'un véhicule
final updateVehicleStatusProvider = StateNotifierProvider<UpdateVehicleStatusNotifier, AsyncValue<void>>((ref) {
  return UpdateVehicleStatusNotifier(ref.watch(vehicleRepositoryProvider));
});

class UpdateVehicleStatusNotifier extends StateNotifier<AsyncValue<void>> {
  final VehicleRepository _repository;

  UpdateVehicleStatusNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> updateStatus({
    required String vehicleId,
    required VehicleStatus newStatus,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repository.updateVehicleStatus(
      vehicleId: vehicleId,
      newStatus: newStatus,
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