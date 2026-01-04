import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alert_model.dart';
import '../models/vehicle_model.dart';
import '../models/notification_model.dart';

class AlertCheckerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool matchesAlert(VehicleModel vehicle, AlertModel alert) {
    print(' Vérification alerte: ${alert.title}');
    print('   Véhicule: ${vehicle.brand} ${vehicle.model} - ${vehicle.price} TND');

    // Marques
    if (alert.brands != null && alert.brands!.isNotEmpty) {
      print('   Critère marques: ${alert.brands} vs ${vehicle.brand}');
      if (!alert.brands!.contains(vehicle.brand)) {
        print('    Marque ne correspond pas');
        return false;
      }
      print('    Marque OK');
    }

    // Prix minimum
    if (alert.minPrice != null) {
      print('   Critère prix min: ${alert.minPrice} vs ${vehicle.price}');
      if (vehicle.price < alert.minPrice!) {
        print('    Prix trop bas');
        return false;
      }
      print('    Prix min OK');
    }

    // Prix maximum
    if (alert.maxPrice != null) {
      print('   Critère prix max: ${alert.maxPrice} vs ${vehicle.price}');
      if (vehicle.price > alert.maxPrice!) {
        print('    Prix trop élevé');
        return false;
      }
      print('    Prix max OK');
    }

    // Année minimum
    if (alert.minYear != null) {
      print('   Critère année min: ${alert.minYear} vs ${vehicle.year}');
      if (vehicle.year < alert.minYear!) {
        print('    Année trop ancienne');
        return false;
      }
      print('    Année min OK');
    }

    // Année maximum
    if (alert.maxYear != null) {
      print('   Critère année max: ${alert.maxYear} vs ${vehicle.year}');
      if (vehicle.year > alert.maxYear!) {
        print('    Année trop récente');
        return false;
      }
      print('    Année max OK');
    }

    // Ville
    if (alert.city != null && alert.city!.isNotEmpty) {
      print('   Critère ville: ${alert.city} vs ${vehicle.city}');
      if (vehicle.city != alert.city) {
        print('    Ville ne correspond pas');
        return false;
      }
      print('    Ville OK');
    }

    // Type de carburant
    if (alert.fuelTypes != null && alert.fuelTypes!.isNotEmpty) {
      final vehicleFuelType = vehicle.fuelType.name.toLowerCase();
      print('   Critère carburant: ${alert.fuelTypes} vs $vehicleFuelType');

      bool fuelMatches = alert.fuelTypes!.any((alertFuel) {
        final alertFuelLower = alertFuel.toLowerCase();
        return alertFuelLower == vehicleFuelType ||
            alertFuelLower == vehicle.fuelType.toString().split('.').last.toLowerCase();
      });

      if (!fuelMatches) {
        print('    Type de carburant ne correspond pas');
        return false;
      }
      print('    Carburant OK');
    }

    // Condition
    if (alert.conditions != null && alert.conditions!.isNotEmpty) {
      final vehicleCondition = vehicle.condition.name.toLowerCase();
      print('   Critère condition: ${alert.conditions} vs $vehicleCondition');

      bool conditionMatches = alert.conditions!.any((alertCond) {
        final alertCondLower = alertCond.toLowerCase();
        return alertCondLower == vehicleCondition ||
            alertCondLower == vehicle.condition.toString().split('.').last.toLowerCase();
      });

      if (!conditionMatches) {
        print('    Condition ne correspond pas');
        return false;
      }
      print('    Condition OK');
    }

    print('    TOUTES LES CONDITIONS CORRESPONDENT !');
    return true;
  }

  Future<void> checkAlertsForVehicle(VehicleModel vehicle) async {
    try {
      print(' === VÉRIFICATION DES ALERTES ===');
      print('   Véhicule: ${vehicle.brand} ${vehicle.model}');
      print('   Prix: ${vehicle.price} TND');
      print('   Année: ${vehicle.year}');
      print('   Ville: ${vehicle.city}');
      print('   Carburant: ${vehicle.fuelType.name}');
      print('   Condition: ${vehicle.condition.name}');
      print('   ID: ${vehicle.id}');

      // Récupérer toutes les alertes actives
      print('\n Récupération des alertes actives...');
      final alertsSnapshot = await _firestore
          .collection('alerts')
          .where('isActive', isEqualTo: true)
          .get();

      print('    Alertes actives trouvées: ${alertsSnapshot.docs.length}');

      if (alertsSnapshot.docs.isEmpty) {
        print('    AUCUNE ALERTE ACTIVE dans Firestore !');
        print('   Créez une alerte dans l\'app pour tester');
        return;
      }

      final batch = _firestore.batch();
      int notificationsCreated = 0;

      for (final alertDoc in alertsSnapshot.docs) {
        try {
          final alert = AlertModel.fromMap(alertDoc.data(), alertDoc.id);
          print('\n' + '='*50);
          print('   Alerte ${alertDoc.id}');
          print('   Titre: "${alert.title}"');
          print('   UserId: ${alert.userId}');
          print('   Critères:');
          if (alert.brands != null) print('     - Marques: ${alert.brands}');
          if (alert.minPrice != null) print('     - Prix min: ${alert.minPrice}');
          if (alert.maxPrice != null) print('     - Prix max: ${alert.maxPrice}');
          if (alert.minYear != null) print('     - Année min: ${alert.minYear}');
          if (alert.maxYear != null) print('     - Année max: ${alert.maxYear}');
          if (alert.city != null) print('     - Ville: ${alert.city}');
          if (alert.fuelTypes != null) print('     - Carburant: ${alert.fuelTypes}');
          if (alert.conditions != null) print('     - Condition: ${alert.conditions}');

          // Vérifier la correspondance
          if (matchesAlert(vehicle, alert)) {
            print('\n    CORRESPONDANCE TROUVÉE !');

            // Créer la notification
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

            print('    Création notification:');
            print('      - Pour user: ${alert.userId}');
            print('      - Véhicule: ${notification.vehicleTitle}');
            print('      - Prix: ${notification.vehiclePrice} TND');

            batch.set(notificationRef, notification.toMap());

            // Mettre à jour l'alerte
            batch.update(alertDoc.reference, {
              'lastTriggered': FieldValue.serverTimestamp(),
              'triggeredCount': FieldValue.increment(1),
            });

            notificationsCreated++;
          } else {
            print('\n   Pas de correspondance pour cette alerte');
          }
        } catch (e) {
          print('    Erreur traitement alerte: $e');
        }
      }

      print('\n' + '='*50);
      if (notificationsCreated > 0) {
        print(' Enregistrement de $notificationsCreated notification(s)...');
        await batch.commit();
        print(' $notificationsCreated notification(s) créée(s) avec succès !');
      } else {
        print(' AUCUNE NOTIFICATION CRÉÉE');
        print('Aucune alerte ne correspond aux critères du véhicule');
      }

      print(' FIN VÉRIFICATION \n');
    } catch (e) {
      print(' ERREUR CRITIQUE dans checkAlertsForVehicle: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }
}