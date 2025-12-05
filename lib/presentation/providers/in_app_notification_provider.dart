import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/in_app_notification_service.dart';
import '../../data/models/in_app_notification_model.dart';

/// Provider del servicio de notificaciones in-app
final inAppNotificationServiceProvider = Provider<InAppNotificationService>((
  ref,
) {
  return InAppNotificationService();
});

/// Provider del stream de notificaciones del usuario
final inAppNotificationsProvider = StreamProvider<List<InAppNotificationModel>>(
  (ref) {
    final service = ref.watch(inAppNotificationServiceProvider);
    return service.getUserNotifications();
  },
);

/// Provider del contador de notificaciones no leídas
final inAppUnreadCountProvider = StreamProvider<int>((ref) {
  final service = ref.watch(inAppNotificationServiceProvider);
  return service.getUnreadCount();
});

/// Provider para verificar si hay notificaciones no leídas
final hasInAppUnreadNotificationsProvider = StreamProvider<bool>((ref) {
  return ref.watch(inAppUnreadCountProvider.stream).map((count) => count > 0);
});
