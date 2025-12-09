import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/chat_service.dart';
import '../../data/models/message_model.dart';
import 'auth_provider.dart';

// Estado del chat individual
class ChatState {
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;
  final String conversationId;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
    required this.conversationId,
  });

  ChatState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
    String? conversationId,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error,
      conversationId: conversationId ?? this.conversationId,
    );
  }
}

// Notifier para gestionar un chat individual
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatService _chatService;
  final String? _userId;
  final String _conversationId;

  ChatNotifier(this._chatService, this._userId, this._conversationId)
    : super(ChatState(conversationId: _conversationId)) {
    // Marcar mensajes como leídos al abrir el chat
    if (_userId != null) {
      _chatService.markAsRead(_conversationId, _userId);
    }
  }

  // Stream de mensajes (se actualiza automáticamente)
  Stream<List<MessageModel>> getMessagesStream() {
    return _chatService.getMessages(_conversationId);
  }

  // Enviar un mensaje
  Future<void> sendMessage(String text, {String type = 'text'}) async {
    if (_userId == null || text.trim().isEmpty) return;

    try {
      state = state.copyWith(isSending: true, error: null);

      await _chatService.sendMessage(
        conversationId: _conversationId,
        senderId: _userId,
        text: text.trim(),
        type: type,
      );

      state = state.copyWith(isSending: false);
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: 'Error sending message: $e',
      );
    }
  }

  // Marcar mensajes como leídos
  Future<void> markAsRead() async {
    if (_userId == null) return;

    try {
      await _chatService.markAsRead(_conversationId, _userId);
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }
}

// Provider factory para crear un chat provider por conversación
final chatProvider =
    StateNotifierProvider.family<ChatNotifier, ChatState, String>((
      ref,
      conversationId,
    ) {
      final user = ref.watch(currentUserProvider);
      final chatService = ref.watch(chatServiceProvider);

      return ChatNotifier(chatService, user?.uid, conversationId);
    });

// Stream provider para mensajes en tiempo real
final messagesStreamProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, conversationId) {
      final notifier = ref.watch(chatProvider(conversationId).notifier);
      return notifier.getMessagesStream();
    });

// Provider del servicio de chat (reutilizado de conversations_provider)
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});
