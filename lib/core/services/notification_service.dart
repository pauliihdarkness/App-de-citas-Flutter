import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'api_client_service.dart';

/// Servicio para gestionar notificaciones push con Firebase Cloud Messaging
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final ApiClientService? _apiClient;

  NotificationService({ApiClientService? apiClient}) : _apiClient = apiClient;

  // Callback para manejar navegación desde notificaciones
  Function(String conversationId)? onNotificationTap;

  /// Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    try {
      // Solicitar permisos
      await requestPermission();

      // Inicializar notificaciones locales
      await _initializeLocalNotifications();

      // Configurar handlers de mensajes
      setupMessageHandlers();

      // Obtener y guardar token
      final token = await getToken();
      if (token != null) {
        final userId = _auth.currentUser?.uid;
        if (userId != null) {
          await saveTokenToFirestore(userId, token);
        }
      }

      // Escuchar cambios de token
      _messaging.onTokenRefresh.listen((newToken) {
        final userId = _auth.currentUser?.uid;
        if (userId != null) {
          saveTokenToFirestore(userId, newToken);
        }
      });

      print('✅ NotificationService inicializado correctamente');
    } catch (e) {
      print('❌ Error inicializando NotificationService: $e');
    }
  }

  /// Inicializar notificaciones locales
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
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
      onDidReceiveNotificationResponse: (details) {
        // Manejar tap en notificación
        if (details.payload != null && onNotificationTap != null) {
          onNotificationTap!(details.payload!);
        }
      },
    );

    // Crear canal de notificaciones para Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      const androidChannel = AndroidNotificationChannel(
        'chat_messages', // id
        'Mensajes de Chat', // nombre
        description: 'Notificaciones de nuevos mensajes en el chat',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(androidChannel);
    }
  }

  /// Solicitar permisos de notificaciones
  Future<bool> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final isGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized;
      print(
        isGranted
            ? '✅ Permisos de notificaciones concedidos'
            : '⚠️ Permisos de notificaciones denegados',
      );

      return isGranted;
    } catch (e) {
      print('❌ Error solicitando permisos: $e');
      return false;
    }
  }

  /// Obtener token FCM del dispositivo
  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        print('📱 Token FCM obtenido: ${token.substring(0, 20)}...');
      }
      return token;
    } catch (e) {
      print('❌ Error obteniendo token: $e');
      return null;
    }
  }

  /// Configurar handlers para mensajes
  void setupMessageHandlers() {
    // Mensajes en foreground (app abierta)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
        '📩 Mensaje recibido en foreground: ${message.notification?.title}',
      );

      // Mostrar notificación local
      if (message.notification != null) {
        showLocalNotification(
          message.notification!.title ?? 'Nuevo mensaje',
          message.notification!.body ?? '',
          message.data,
        );
      }
    });

    // Mensajes cuando la app está en background pero abierta
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📩 Notificación tocada (app en background)');
      _handleNotificationTap(message.data);
    });

    // Verificar si la app se abrió desde una notificación
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('📩 App abierta desde notificación');
        _handleNotificationTap(message.data);
      }
    });
  }

  /// Manejar tap en notificación
  void _handleNotificationTap(Map<String, dynamic> data) {
    final conversationId = data['conversationId'] as String?;
    if (conversationId != null && onNotificationTap != null) {
      onNotificationTap!(conversationId);
    }
  }

  /// Mostrar notificación local
  Future<void> showLocalNotification(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'chat_messages',
        'Mensajes de Chat',
        channelDescription: 'Notificaciones de nuevos mensajes en el chat',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final conversationId = data['conversationId'] as String?;

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000, // ID único
        title,
        body,
        notificationDetails,
        payload: conversationId, // Para navegación
      );

      print('✅ Notificación local mostrada: $title');
    } catch (e) {
      print('❌ Error mostrando notificación local: $e');
    }
  }

  /// Guardar token en Firestore y Backend
  Future<void> saveTokenToFirestore(String userId, String token) async {
    try {
      // 1. Guardar en Firestore (Mantener lógica existente)
      final tokenRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('private')
          .doc('fcmTokens');

      await tokenRef.set({
        'tokens': FieldValue.arrayUnion([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ Token guardado en Firestore');

      // 2. Enviar a Backend (Nueva lógica)
      if (_apiClient != null) {
        await _apiClient.registerFcmToken(userId, token);
      }
    } catch (e) {
      print('❌ Error guardando token: $e');
    }
  }

  /// Eliminar token de Firestore y Backend
  Future<void> deleteTokenFromFirestore(String userId, String token) async {
    try {
      // 1. Eliminar de Firestore
      final tokenRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('private')
          .doc('fcmTokens');

      await tokenRef.update({
        'tokens': FieldValue.arrayRemove([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Token eliminado de Firestore');

      // 2. Eliminar del Backend
      if (_apiClient != null) {
        await _apiClient.unregisterFcmToken(userId, token);
      }
    } catch (e) {
      print('❌ Error eliminando token: $e');
    }
  }

  /// Eliminar todos los tokens del usuario actual
  Future<void> deleteAllTokens() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final token = await getToken();
      if (token != null) {
        await deleteTokenFromFirestore(userId, token);
      }
    } catch (e) {
      print('❌ Error eliminando tokens: $e');
    }
  }

  /// Obtener tokens de un usuario específico
  Future<List<String>> getUserTokens(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('private')
          .doc('fcmTokens')
          .get();

      if (!doc.exists) return [];

      final data = doc.data();
      final tokens = data?['tokens'] as List<dynamic>?;

      return tokens?.map((t) => t.toString()).toList() ?? [];
    } catch (e) {
      print('❌ Error obteniendo tokens del usuario: $e');
      return [];
    }
  }
}

// Handler para mensajes en background (debe ser top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📩 Mensaje recibido en background: ${message.notification?.title}');
  // El sistema operativo maneja la notificación automáticamente
}
