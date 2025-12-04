import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/chat_service.dart';
import '../../data/models/conversation_model.dart';
import 'auth_provider.dart';

// Provider del servicio de chat
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

// Estado de las conversaciones
class ConversationsState {
  final List<ConversationModel> conversations;
  final bool isLoading;
  final String? error;

  const ConversationsState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  ConversationsState copyWith({
    List<ConversationModel>? conversations,
    bool? isLoading,
    String? error,
  }) {
    return ConversationsState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier para gestionar las conversaciones
class ConversationsNotifier extends StateNotifier<ConversationsState> {
  final ChatService _chatService;
  final String? _userId;

  ConversationsNotifier(this._chatService, this._userId)
    : super(const ConversationsState());

  // Stream de conversaciones (se actualiza automáticamente)
  Stream<List<ConversationModel>>? getConversationsStream() {
    if (_userId == null) return null;
    return _chatService.getConversations(_userId);
  }

  // Eliminar una conversación
  Future<void> deleteConversation(String conversationId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _chatService.deleteConversation(conversationId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error deleting conversation: $e',
      );
    }
  }

  // Obtener o crear conversación con otro usuario
  Future<String?> getOrCreateConversation(String otherUserId) async {
    if (_userId == null) return null;

    try {
      state = state.copyWith(isLoading: true, error: null);
      final conversationId = await _chatService.getOrCreateConversation(
        _userId,
        otherUserId,
      );
      state = state.copyWith(isLoading: false);
      return conversationId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error creating conversation: $e',
      );
      return null;
    }
  }
}

// Provider global de conversaciones
final conversationsProvider =
    StateNotifierProvider<ConversationsNotifier, ConversationsState>((ref) {
      final user = ref.watch(currentUserProvider);
      final chatService = ref.watch(chatServiceProvider);

      return ConversationsNotifier(chatService, user?.uid);
    });

// Stream provider para conversaciones en tiempo real
final conversationsStreamProvider = StreamProvider<List<ConversationModel>>((
  ref,
) {
  final notifier = ref.watch(conversationsProvider.notifier);
  final stream = notifier.getConversationsStream();

  if (stream == null) {
    return Stream.value([]);
  }

  return stream;
});

// Provider para obtener una conversación específica por ID
final conversationByIdProvider =
    FutureProvider.family<ConversationModel?, String>((
      ref,
      conversationId,
    ) async {
      final chatService = ref.watch(chatServiceProvider);
      return await chatService.getConversation(conversationId);
    });
