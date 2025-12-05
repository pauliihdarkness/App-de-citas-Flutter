import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para notificaciones in-app (promocionales, sistema, features)
class InAppNotificationModel {
  final String id;
  final String type; // 'promotional', 'system', 'feature', 'tip'
  final String title;
  final String body;
  final String? imageUrl;
  final String? actionUrl; // Ruta de navegación al tocar
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String priority; // 'high', 'normal', 'low'
  final bool read;
  final DateTime? readAt;
  final bool dismissed;

  InAppNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    this.actionUrl,
    required this.createdAt,
    this.expiresAt,
    this.priority = 'normal',
    this.read = false,
    this.readAt,
    this.dismissed = false,
  });

  /// Crear desde documento de Firestore (user notification)
  factory InAppNotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return InAppNotificationModel(
      id: doc.id,
      type: data['type'] ?? 'system',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      imageUrl: data['imageUrl'],
      actionUrl: data['actionUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      priority: data['priority'] ?? 'normal',
      read: data['read'] ?? false,
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
      dismissed: data['dismissed'] ?? false,
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'body': body,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (actionUrl != null) 'actionUrl': actionUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
      'priority': priority,
      'read': read,
      if (readAt != null) 'readAt': Timestamp.fromDate(readAt!),
      'dismissed': dismissed,
    };
  }

  /// Copiar con modificaciones
  InAppNotificationModel copyWith({
    String? id,
    String? type,
    String? title,
    String? body,
    String? imageUrl,
    String? actionUrl,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? priority,
    bool? read,
    DateTime? readAt,
    bool? dismissed,
  }) {
    return InAppNotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      priority: priority ?? this.priority,
      read: read ?? this.read,
      readAt: readAt ?? this.readAt,
      dismissed: dismissed ?? this.dismissed,
    );
  }

  /// Verificar si la notificación ha expirado
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Obtener ícono según el tipo
  String get iconEmoji {
    switch (type) {
      case 'promotional':
        return '🎉';
      case 'feature':
        return '✨';
      case 'tip':
        return '💡';
      case 'system':
        return '📢';
      default:
        return '📬';
    }
  }
}
