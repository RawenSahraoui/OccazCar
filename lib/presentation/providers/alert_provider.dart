import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/alert_model.dart';
import '../../data/repositories/alert_repository.dart';
import 'auth_provider.dart';

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return AlertRepository();
});

final userAlertsProvider = StreamProvider<List<AlertModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);

  final repository = ref.watch(alertRepositoryProvider);
  return repository.getUserAlerts(user.uid);
});

final activeAlertsCountProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return 0;

  final repository = ref.watch(alertRepositoryProvider);
  return await repository.getActiveAlertsCount(user.uid);
});

final alertNotifierProvider = Provider<AlertNotifier>((ref) {
  return AlertNotifier(ref);
});

class AlertNotifier {
  final Ref ref;
  AlertNotifier(this.ref);

  Future<bool> createAlert(AlertModel alert) async {
    final repository = ref.read(alertRepositoryProvider);
    final result = await repository.createAlert(alert);
    return result.isSuccess;
  }

  Future<bool> updateAlert(String alertId, Map<String, dynamic> data) async {
    final repository = ref.read(alertRepositoryProvider);
    final result = await repository.updateAlert(alertId, data);
    return result.isSuccess;
  }

  Future<bool> deleteAlert(String alertId) async {
    final repository = ref.read(alertRepositoryProvider);
    final result = await repository.deleteAlert(alertId);
    return result.isSuccess;
  }

  Future<bool> toggleAlert(String alertId, bool isActive) async {
    final repository = ref.read(alertRepositoryProvider);
    final result = await repository.toggleAlert(alertId, isActive);
    return result.isSuccess;
  }
}