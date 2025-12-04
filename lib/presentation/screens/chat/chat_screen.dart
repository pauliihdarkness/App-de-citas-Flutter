import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/users_provider.dart';
import '../../providers/conversations_provider.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/chat_input.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showOptionsMenu(BuildContext context, String otherUserId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.flag, color: Colors.orange),
              title: const Text('Reportar usuario'),
              onTap: () {
                context.pop();
                _showReportDialog(context, otherUserId);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.ban, color: Colors.red),
              title: const Text('Bloquear usuario'),
              onTap: () {
                context.pop();
                _showBlockDialog(context, otherUserId);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context, String otherUserId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportar usuario'),
        content: const Text(
          '¿Estás seguro de que quieres reportar a este usuario? Revisaremos el caso.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implementar lógica de reporte
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuario reportado')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Reportar'),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog(BuildContext context, String otherUserId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bloquear usuario'),
        content: const Text(
          '¿Estás seguro de que quieres bloquear a este usuario? No podrán contactarte.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implementar lógica de bloqueo
              Navigator.pop(context);
              context.pop(); // Volver a la lista de conversaciones
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuario bloqueado')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Bloquear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(
      messagesStreamProvider(widget.conversationId),
    );
    final chatState = ref.watch(chatProvider(widget.conversationId));
    final currentUser = ref.watch(currentUserProvider);

    // Obtener la conversación para extraer los participantes
    final conversationAsync = ref.watch(
      conversationByIdProvider(widget.conversationId),
    );

    return conversationAsync.when(
      data: (conversation) {
        if (conversation == null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: () => context.pop(),
              ),
              title: const Text('Conversación no encontrada'),
            ),
            body: const Center(
              child: Text('No se pudo cargar la conversación'),
            ),
          );
        }

        // Obtener el ID del otro usuario desde la conversación
        final otherUserId = conversation.getOtherParticipantId(
          currentUser?.uid ?? '',
        );

        print('🔍 ConversationId: ${widget.conversationId}');
        print('🔍 Participants: ${conversation.users}');
        print('🔍 CurrentUserId: ${currentUser?.uid}');
        print('🔍 OtherUserId: $otherUserId');

        final otherUserAsync = ref.watch(userByIdProvider(otherUserId));

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () => context.pop(),
            ),
            title: otherUserAsync.when(
              data: (otherUser) {
                if (otherUser == null) {
                  return const Text('Usuario');
                }
                return InkWell(
                  onTap: () {
                    // Navegar al perfil del usuario (sin botones de acción)
                    context.push('/user/${otherUser.uid}?hideActions=true');
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: otherUser.photos.isNotEmpty
                            ? NetworkImage(otherUser.photos.first)
                            : null,
                        child: otherUser.photos.isEmpty
                            ? const Icon(LucideIcons.user, size: 20)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              otherUser.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              'Toca para ver perfil',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary,
                    child: const Icon(
                      LucideIcons.user,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Cargando...'),
                ],
              ),
              error: (_, __) => const Text('Usuario'),
            ),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.moreVertical),
                onPressed: () => _showOptionsMenu(context, otherUserId),
              ),
            ],
          ),
          body: Column(
            children: [
              // Lista de mensajes
              Expanded(
                child: messagesAsync.when(
                  data: (messages) {
                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.messageCircle,
                              size: 64,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '¡Hicieron match!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Envía un mensaje para empezar',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true, // Mensajes más recientes abajo
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == currentUser?.uid;

                        // Verificar si mostrar timestamp (cada 5 minutos)
                        bool showTimestamp = false;
                        if (index == messages.length - 1) {
                          showTimestamp = true;
                        } else {
                          final nextMessage = messages[index + 1];
                          final diff = message.timestamp
                              .difference(nextMessage.timestamp)
                              .inMinutes;
                          showTimestamp = diff > 5;
                        }

                        return MessageBubble(
                          message: message,
                          isMe: isMe,
                          showTimestamp: showTimestamp,
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          LucideIcons.alertCircle,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Error al cargar mensajes',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Input de mensaje
              ChatInput(
                controller: _textController,
                isSending: chatState.isSending,
                onSend: (text) async {
                  if (text.trim().isEmpty) return;

                  await ref
                      .read(chatProvider(widget.conversationId).notifier)
                      .sendMessage(text);

                  _textController.clear();
                  _scrollToBottom();
                },
              ),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.pop(),
          ),
          title: const Text('Error'),
        ),
        body: Center(child: Text('Error al cargar conversación: $error')),
      ),
    );
  }
}
