import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alert_model.dart';
import '../models/vehicle_model.dart';
import '../models/notification_model.dart';

class AlertCheckerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool matchesAlert(VehicleModel vehicle, AlertModel alert) {
    if (alert.brands != null && alert.brands!.isNotEmpty) {
      if (!alert.brands!.contains(vehicle.brand)) return false;
    }

    if (alert.minPrice != null && vehicle.price < alert.minPrice!) return false;
    if (alert.maxPrice != null && vehicle.price > alert.maxPrice!) return false;

    if (alert.minYear != null && vehicle.year < alert.minYear!) return false;
    if (alert.maxYear != null && vehicle.year > alert.maxYear!) return false;

    if (alert.city != null && vehicle.city != alert.city) return false;

    if (alert.fuelTypes != null && alert.fuelTypes!.isNotEmpty) {
      if (!alert.fuelTypes!.contains(vehicle.fuelType.name)) return false;
    }

    if (alert.conditions != null && alert.conditions!.isNotEmpty) {
      if (!alert.conditions!.contains(vehicle.condition.name)) return false;
    }

    return true;
  }

  Future<void> checkAlertsForVehicle(VehicleModel vehicle) async {
    try {
      final alertsSnapshot = await _firestore
          .collection('alerts')
          .where('isActive', isEqualTo: true)
          .get();

      if (alertsSnapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      int notificationsCreated = 0;

      for (final alertDoc in alertsSnapshot.docs) {
        final alert = AlertModel.fromMap(alertDoc.data(), alertDoc.id);

        if (matchesAlert(vehicle, alert)) {
          final notificationRef = _firestore.collection('notifications').doc();
          final notification = NotificationModel(
            id: notificationRef.id,
            userId: alert.userId,
            vehicleId: vehicle.id,
            alertId: alert.id,
            alertTitle: alert.title,
            vehicleTitle: '${vehicle.brand} ${vehicle.model}',
            vehicleBrand: vehicle.brand,
            vehicleModel: vehicle.model,
            vehiclePrice: vehicle.price,
            vehicleYear: vehicle.year,
            vehicleImageUrl: vehicle.thumbnailUrl,
            vehicleCity: vehicle.city,
            createdAt: DateTime.now(),
            read: false,
          );

          batch.set(notificationRef, notification.toMap());

          batch.update(alertDoc.reference, {
            'lastTriggered': FieldValue.serverTimestamp(),
          });

          notificationsCreated++;
        }
      }

      if (notificationsCreated > 0) {
        await batch.commit();
        print('✅ $notificationsCreated notification(s) creee(s)');
      }
    } catch (e) {
      print('❌ Erreur alertes: $e');
    }
  }
}