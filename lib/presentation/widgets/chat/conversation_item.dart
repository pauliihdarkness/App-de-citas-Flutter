import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../config/theme.dart';
import '../../../data/models/conversation_model.dart';
import '../../providers/users_provider.dart';
import '../../providers/notification_provider.dart';
import '../notification_badge.dart';

class ConversationItem extends ConsumerWidget {
  final ConversationModel conversation;
  final String otherUserId;
  final String currentUserId;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ConversationItem({
    super.key,
    required this.conversation,
    required this.otherUserId,
    required this.currentUserId,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otherUserAsync = ref.watch(userByIdProvider(otherUserId));

    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(LucideIcons.trash2, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (onDelete != null) {
          onDelete!();
        }
        return false; // No eliminar automáticamente, lo manejamos en onDelete
      },
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Foto de perfil con badge de mensajes no leídos
              Consumer(
                builder: (context, ref, child) {
                  final unreadCount = ref.watch(
                    conversationUnreadCountProvider(conversation.id),
                  );

                  return unreadCount.when(
                    data: (count) => NotificationBadge(
                      count: count,
                      child: otherUserAsync.when(
                        data: (otherUser) {
                          if (otherUser == null) {
                            return _buildDefaultAvatar();
                          }

                          return CircleAvatar(
                            radius: 28,
                            backgroundImage: otherUser.photos.isNotEmpty
                                ? NetworkImage(otherUser.photos.first)
                                : null,
                            child: otherUser.photos.isEmpty
                                ? const Icon(LucideIcons.user)
                                : null,
                          );
                        },
                        loading: () => _buildDefaultAvatar(),
                        error: (_, __) => _buildDefaultAvatar(),
                      ),
                    ),
                    loading: () => otherUserAsync.when(
                      data: (otherUser) {
                        if (otherUser == null) {
                          return _buildDefaultAvatar();
                        }

                        return CircleAvatar(
                          radius: 28,
                          backgroundImage: otherUser.photos.isNotEmpty
                              ? NetworkImage(otherUser.photos.first)
                              : null,
                          child: otherUser.photos.isEmpty
                              ? const Icon(LucideIcons.user)
                              : null,
                        );
                      },
                      loading: () => _buildDefaultAvatar(),
                      error: (_, __) => _buildDefaultAvatar(),
                    ),
                    error: (_, __) => otherUserAsync.when(
                      data: (otherUser) {
                        if (otherUser == null) {
                          return _buildDefaultAvatar();
                        }

                        return CircleAvatar(
                          radius: 28,
                          backgroundImage: otherUser.photos.isNotEmpty
                              ? NetworkImage(otherUser.photos.first)
                              : null,
                          child: otherUser.photos.isEmpty
                              ? const Icon(LucideIcons.user)
                              : null,
                        );
                      },
                      loading: () => _buildDefaultAvatar(),
                      error: (_, __) => _buildDefaultAvatar(),
                    ),
                  );
                },
              ),

              const SizedBox(width: 12),

              // Información de la conversación
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: otherUserAsync.when(
                            data: (otherUser) => Text(
                              otherUser?.name ?? 'Usuario',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            loading: () => Text(
                              'Cargando...',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            error: (_, __) => Text(
                              'Usuario',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (conversation.lastMessageTime != null)
                          Text(
                            _formatTimestamp(conversation.lastMessageTime!),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage?.isEmpty ?? true
                                ? 'Hicieron match'
                                : conversation.lastMessage!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return CircleAvatar(
      radius: 28,
      backgroundColor: AppColors.glassBg,
      child: const Icon(LucideIcons.user, color: AppColors.textSecondary),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    timeago.setLocaleMessages('es', timeago.EsMessages());
    return timeago.format(timestamp, locale: 'es');
  }
}
