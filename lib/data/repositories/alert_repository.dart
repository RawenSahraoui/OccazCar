import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alert_model.dart';
import '../../core/utils/result.dart';

class AlertRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Result<String>> createAlert(AlertModel alert) async {
    try {
      final docRef = await _firestore.collection('alerts').add(alert.toMap());
      return Result.success(docRef.id);
    } catch (e) {
      return Result.failure('Erreur lors de la création de l\'alerte: $e');
    }
  }

  Stream<List<AlertModel>> getUserAlerts(String userId) {
    return _firestore
        .collection('alerts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AlertModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<Result<void>> updateAlert(String alertId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('alerts').doc(alertId).update(data);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Erreur lors de la mise à jour: $e');
    }
  }

  Future<Result<void>> deleteAlert(String alertId) async {
    try {
      await _firestore.collection('alerts').doc(alertId).delete();
      return Result.success(null);
    } catch (e) {
      return Result.failure('Erreur lors de la suppression: $e');
    }
  }

  Future<Result<void>> toggleAlert(String alertId, bool isActive) async {
    try {
      await _firestore.collection('alerts').doc(alertId).update({
        'isActive': isActive,
      });
      return Result.success(null);
    } catch (e) {
      return Result.failure('Erreur: $e');
    }
  }

  Future<Result<AlertModel>> getAlertById(String alertId) async {
    try {
      final doc = await _firestore.collection('alerts').doc(alertId).get();
      if (!doc.exists) {
        return Result.failure('Alerte non trouvée');
      }
      return Result.success(AlertModel.fromMap(doc.data()!, doc.id));
    } catch (e) {
      return Result.failure('Erreur: $e');
    }
  }

  Future<int> getActiveAlertsCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('alerts')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
  Future<List<AlertModel>> getAllActiveAlerts() async {
    final snapshot = await _firestore
        .collection('alerts')
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => AlertModel.fromMap(doc.data(), doc.id))
        .toList();
  }

}