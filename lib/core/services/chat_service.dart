import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';
import 'notification_service.dart';

/// Servicio para gestionar el chat en tiempo real con Firestore
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  /// Generar ID único para match (ordenado alfabéticamente)
  /// Formato: userId1_userId2 donde userId1 < userId2
  String _getMatchId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// Obtener o crear un match entre dos usuarios
  Future<String> getOrCreateConversation(String userId1, String userId2) async {
    final matchId = _getMatchId(userId1, userId2);
    final matchRef = _firestore.collection('matches').doc(matchId);

    final doc = await matchRef.get();

    if (!doc.exists) {
      // Crear nuevo match
      final users = [userId1, userId2]..sort();
      await matchRef.set({
        'users': users,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': null,
        'lastMessageTime': null,
        'unreadCount': {userId1: 0, userId2: 0},
      });
    }

    return matchId;
  }

  /// Stream de matches (conversaciones) del usuario
  Stream<List<ConversationModel>> getConversations(String userId) {
    return _firestore
        .collection('matches')
        .where('users', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ConversationModel.fromFirestore(doc))
              .toList();
        });
  }

  /// Stream de mensajes de un match
  Stream<List<MessageModel>> getMessages(String matchId) {
    return _firestore
        .collection('matches')
        .doc(matchId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50) // Cargar últimos 50 mensajes
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MessageModel.fromFirestore(doc))
              .toList();
        });
  }

  /// Enviar un mensaje
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
    String type = 'text',
  }) async {
    final matchRef = _firestore.collection('matches').doc(conversationId);

    // Verificar que el match existe
    final matchDoc = await matchRef.get();
    if (!matchDoc.exists) {
      throw Exception('Match not found');
    }

    // Crear el mensaje (sin campo 'type' según firestore-structure.md)
    final messageData = {
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    };

    // Agregar mensaje a la subcolección
    await matchRef.collection('messages').add(messageData);

    // Obtener el otro usuario del match
    final matchData = matchDoc.data() as Map<String, dynamic>;
    final users = List<String>.from(matchData['users'] ?? []);
    final recipientId = users.firstWhere(
      (id) => id != senderId,
      orElse: () => '',
    );

    // Incrementar contador de mensajes no leídos para el destinatario
    final unreadCount = matchData['unreadCount'] as Map<String, dynamic>? ?? {};
    final currentCount = (unreadCount[recipientId] as num?)?.toInt() ?? 0;
    unreadCount[recipientId] = currentCount + 1;

    // Actualizar el match con el último mensaje y contador
    await matchRef.update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount': unreadCount,
    });

    // Obtener información del remitente para la notificación
    try {
      final senderDoc = await _firestore
          .collection('users')
          .doc(senderId)
          .get();
      if (senderDoc.exists) {
        // Obtener tokens del destinatario
        final recipientTokens = await _notificationService.getUserTokens(
          recipientId,
        );

        // Por ahora solo mostramos notificación local si el destinatario está en la app
        // En el futuro, aquí se llamaría a Cloud Functions para enviar push notification
        if (recipientTokens.isNotEmpty) {
          print('📱 Destinatario tiene ${recipientTokens.length} token(s) FCM');
          // TODO: Implementar envío de notificación push via Cloud Functions
        }
      }
    } catch (e) {
      print('⚠️ Error obteniendo información del remitente: $e');
    }
  }

  /// Marcar mensajes como leídos
  Future<void> markAsRead(String matchId, String userId) async {
    final matchRef = _firestore.collection('matches').doc(matchId);

    // Marcar mensajes individuales como leídos
    final messagesSnapshot = await matchRef
        .collection('messages')
        .where('senderId', isNotEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();

    if (messagesSnapshot.docs.isNotEmpty) {
      final batch = _firestore.batch();
      for (final doc in messagesSnapshot.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    }

    // Siempre resetear contador de mensajes no leídos para este usuario
    // (incluso si no había mensajes sin leer, para corregir inconsistencias)
    await matchRef.update({'unreadCount.$userId': 0});
  }

  /// Eliminar un match (unmatch)
  Future<void> deleteConversation(String matchId) async {
    final matchRef = _firestore.collection('matches').doc(matchId);

    // Eliminar todos los mensajes
    final messagesSnapshot = await matchRef.collection('messages').get();
    final batch = _firestore.batch();

    for (final doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Eliminar el match
    batch.delete(matchRef);

    await batch.commit();
  }

  /// Obtener información de un match específico
  Future<ConversationModel?> getConversation(String matchId) async {
    final doc = await _firestore.collection('matches').doc(matchId).get();

    if (!doc.exists) return null;

    return ConversationModel.fromFirestore(doc);
  }
}
