import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';
import 'auth_provider.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final userNotificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);

  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getUserNotifications(user.uid);
});

final unreadCountProvider = StreamProvider<int>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(0);

  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getUnreadCount(user.uid);
});

final notificationNotifierProvider = Provider<NotificationNotifier>((ref) {
  return NotificationNotifier(ref);
});

class NotificationNotifier {
  final Ref ref;
  NotificationNotifier(this.ref);

  Future<bool> markAsRead(String notificationId) async {
    final repository = ref.read(notificationRepositoryProvider);
    final result = await repository.markAsRead(notificationId);
    return result.isSuccess;
  }

  Future<bool> markAllAsRead(String userId) async {
    final repository = ref.read(notificationRepositoryProvider);
    final result = await repository.markAllAsRead(userId);
    return result.isSuccess;
  }

  Future<bool> deleteNotification(String notificationId) async {
    final repository = ref.read(notificationRepositoryProvider);
    final result = await repository.deleteNotification(notificationId);
    return result.isSuccess;
  }
}