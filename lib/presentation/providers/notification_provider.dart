import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/notification_service.dart';
import 'api_client_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Provider del servicio de notificaciones
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationService(apiClient: apiClient);
});

/// Provider para el contador total de mensajes no leídos
final totalUnreadMessagesProvider = StreamProvider<int>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(0);

  return FirebaseFirestore.instance
      .collection('matches')
      .where('users', arrayContains: user.uid)
      .snapshots()
      .map((snapshot) {
        int total = 0;
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final unreadCount = data['unreadCount'] as Map<String, dynamic>?;
          if (unreadCount != null && unreadCount.containsKey(user.uid)) {
            total += (unreadCount[user.uid] as num?)?.toInt() ?? 0;
          }
        }
        return total;
      });
});

/// Provider para el contador de mensajes no leídos por conversación
final conversationUnreadCountProvider = StreamProvider.family<int, String>((
  ref,
  conversationId,
) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(0);

  return FirebaseFirestore.instance
      .collection('matches')
      .doc(conversationId)
      .snapshots()
      .map((snapshot) {
        if (!snapshot.exists) return 0;

        final data = snapshot.data();
        final unreadCount = data?['unreadCount'] as Map<String, dynamic>?;

        print('🔍 DEBUG - Conversation: $conversationId');
        print('🔍 DEBUG - Current User: ${user.uid}');
        print('🔍 DEBUG - UnreadCount Map: $unreadCount');

        if (unreadCount != null && unreadCount.containsKey(user.uid)) {
          final count = (unreadCount[user.uid] as num?)?.toInt() ?? 0;
          print('🔍 DEBUG - Count for ${user.uid}: $count');
          return count;
        }

        print('🔍 DEBUG - No unread count found, returning 0');
        return 0;
      });
});

/// Provider para verificar si hay notificaciones no leídas
final hasUnreadNotificationsProvider = StreamProvider<bool>((ref) {
  return ref
      .watch(totalUnreadMessagesProvider.stream)
      .map((count) => count > 0);
});
