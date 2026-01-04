import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alert_model.dart';
import '../models/vehicle_model.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createNotification({
    required AlertModel alert,
    required VehicleModel vehicle,
  }) async {
    final notification = NotificationModel(
      id: '',
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

    // Ajouter la notification
    await _firestore.collection('notifications').add(notification.toMap());

    // Mettre à jour l'alerte
    await _firestore.collection('alerts').doc(alert.id).update({
      'lastTriggered': Timestamp.now(),
      'triggeredCount': FieldValue.increment(1),
    });
  }
}
