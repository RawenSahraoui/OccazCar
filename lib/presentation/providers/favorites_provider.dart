import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/vehicle_model.dart';
import 'auth_provider.dart';

// Provider pour vérifier si un véhicule est en favoris
final isFavoriteProvider = StreamProvider.family<bool, String>((ref, vehicleId) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(false);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('favorites')
      .doc(vehicleId)
      .snapshots()
      .map((doc) => doc.exists);
});

// Provider pour la liste des favoris
final favoritesListProvider = StreamProvider<List<VehicleModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('favorites')
      .orderBy('addedAt', descending: true)
      .snapshots()
      .asyncMap((snapshot) async {
    final List<VehicleModel> favorites = [];

    for (var doc in snapshot.docs) {
      final vehicleId = doc.id;
      try {
        final vehicleDoc = await FirebaseFirestore.instance
            .collection('vehicles')
            .doc(vehicleId)
            .get();

        if (vehicleDoc.exists) {
          favorites.add(VehicleModel.fromMap(vehicleDoc.data()!));
        }
      } catch (e) {
        print('Erreur lors de la récupération du véhicule $vehicleId: $e');
      }
    }

    return favorites;
  });
});

// Provider pour ajouter/retirer des favoris
final favoritesNotifierProvider = Provider<FavoritesNotifier>((ref) {
  return FavoritesNotifier(ref);
});

class FavoritesNotifier {
  final Ref ref;
  FavoritesNotifier(this.ref);

  Future<void> toggleFavorite(String vehicleId) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(vehicleId);

    final doc = await favRef.get();

    if (doc.exists) {
      // Retirer des favoris
      await favRef.delete();
    } else {
      // Ajouter aux favoris
      await favRef.set({
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<bool> isFavorite(String vehicleId) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return false;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(vehicleId)
        .get();

    return doc.exists;
  }

  Future<List<VehicleModel>> getFavorites() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .get();

    final List<VehicleModel> favorites = [];

    for (var doc in snapshot.docs) {
      final vehicleId = doc.id;
      try {
        final vehicleDoc = await FirebaseFirestore.instance
            .collection('vehicles')
            .doc(vehicleId)
            .get();

        if (vehicleDoc.exists) {
          favorites.add(VehicleModel.fromMap(vehicleDoc.data()!));
        }
      } catch (e) {
        print('Erreur: $e');
      }
    }

    return favorites;
  }
}