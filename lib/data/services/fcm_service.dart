import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Demander la permission
    await _requestPermission();

    // Configurer les notifications locales
    await _setupLocalNotifications();

    // Obtenir le token FCM
    final token = await _messaging.getToken();
    if (token != null) {
      await _saveTokenToFirestore(token);
    }

    // Écouter les changements de token
    _messaging.onTokenRefresh.listen(_saveTokenToFirestore);

    // Gérer les messages en premier plan
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Gérer les messages en arrière-plan
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Permission accordée');
    } else {
      print('❌ Permission refusée');
    }
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    // Créer un canal de notification Android
    const androidChannel = AndroidNotificationChannel(
      'occazcar_alerts',
      'Alertes OccazCar',
      description: 'Notifications pour les nouvelles annonces correspondantes',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
    AndroidFlutterLocalNotificationsPlugin()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _saveTokenToFirestore(String token) async {
    final userId = FirebaseFirestore.instance
        .collection('users')
        .doc(); // Remplacer par l'ID utilisateur réel

    await FirebaseFirestore.instance
        .collection('fcm_tokens')
        .doc(userId.id)
        .set({
      'token': token,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'occazcar_alerts',
          'Alertes OccazCar',
          channelDescription: 'Notifications pour les nouvelles annonces',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data['vehicleId'],
    );
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    final vehicleId = message.data['vehicleId'];
    if (vehicleId != null) {
      // Naviguer vers le détail du véhicule
      print('Navigation vers: /vehicle/$vehicleId');
    }
  }

  void _handleNotificationTap(NotificationResponse response) {
    final vehicleId = response.payload;
    if (vehicleId != null) {
      // Naviguer vers le détail du véhicule
      print('Navigation vers: /vehicle/$vehicleId');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}