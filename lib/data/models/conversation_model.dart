import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para un match (conversación) entre dos usuarios
class ConversationModel {
  final String id;
  final List<String> users; // [userId1, userId2] ordenados alfabéticamente
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final DateTime createdAt;

  const ConversationModel({
    required this.id,
    required this.users,
    this.lastMessage,
    this.lastMessageTime,
    required this.createdAt,
  });

  /// Crear desde Firestore
  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConversationModel(
      id: doc.id,
      users: List<String>.from(data['users'] ?? []),
      lastMessage: data['lastMessage'],
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'users': users,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Crear copia con cambios
  ConversationModel copyWith({
    String? id,
    List<String>? users,
    String? lastMessage,
    DateTime? lastMessageTime,
    DateTime? createdAt,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      users: users ?? this.users,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Obtener el ID del otro participante (no el usuario actual)
  String getOtherParticipantId(String currentUserId) {
    return users.firstWhere((id) => id != currentUserId, orElse: () => '');
  }

  @override
  String toString() {
    return 'ConversationModel(id: $id, users: $users, lastMessage: $lastMessage, lastMessageTime: $lastMessageTime)';
  }
}
