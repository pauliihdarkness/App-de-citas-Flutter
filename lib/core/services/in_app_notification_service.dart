import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/in_app_notification_model.dart';

/// Servicio para gestionar notificaciones in-app
class InAppNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream de notificaciones del usuario actual
  Stream<List<InAppNotificationModel>> getUserNotifications() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('dismissed', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => InAppNotificationModel.fromFirestore(doc))
              .where((notification) => !notification.isExpired)
              .toList();
        });
  }

  /// Marcar notificación como leída
  Future<void> markAsRead(String notificationId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true, 'readAt': FieldValue.serverTimestamp()});
  }

  /// Marcar todas las notificaciones como leídas
  Future<void> markAllAsRead() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final unreadDocs = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in unreadDocs.docs) {
      batch.update(doc.reference, {
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Descartar notificación
  Future<void> dismissNotification(String notificationId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'dismissed': true});
  }

  /// Crear notificación de bienvenida para nuevo usuario
  Future<void> createWelcomeNotification(String userId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
          'type': 'system',
          'title': '¡Bienvenido a App de Citas! 💕',
          'body': 'Completa tu perfil para empezar a hacer matches',
          'actionUrl': '/edit-profile',
          'priority': 'high',
          'createdAt': FieldValue.serverTimestamp(),
          'expiresAt': Timestamp.fromDate(
            DateTime.now().add(const Duration(days: 7)),
          ),
          'read': false,
          'dismissed': false,
        });
  }

  /// Crear notificación de tip
  Future<void> createTipNotification(
    String userId,
    String title,
    String body, {
    String? actionUrl,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
          'type': 'tip',
          'title': title,
          'body': body,
          if (actionUrl != null) 'actionUrl': actionUrl,
          'priority': 'normal',
          'createdAt': FieldValue.serverTimestamp(),
          'expiresAt': Timestamp.fromDate(
            DateTime.now().add(const Duration(days: 3)),
          ),
          'read': false,
          'dismissed': false,
        });
  }

  /// Obtener contador de notificaciones no leídas
  Stream<int> getUnreadCount() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(0);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .where('dismissed', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => InAppNotificationModel.fromFirestore(doc))
              .where((notification) => !notification.isExpired)
              .length;
        });
  }
}
