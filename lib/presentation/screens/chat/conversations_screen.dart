import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme.dart';
import '../../providers/conversations_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/chat/conversation_item.dart';

import '../../widgets/chat/matches_list.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsStreamProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mensajes'), centerTitle: true),
      body: conversationsAsync.when(
        data: (allConversations) {
          // Separar nuevos matches (sin mensajes) de conversaciones activas
          final newMatches = allConversations
              .where((c) => c.lastMessage == null || c.lastMessage!.isEmpty)
              .toList();

          final activeConversations = allConversations
              .where((c) => c.lastMessage != null && c.lastMessage!.isNotEmpty)
              .toList();

          if (allConversations.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(conversationsStreamProvider);
            },
            child: CustomScrollView(
              slivers: [
                // Matches List (Story bubbles)
                if (newMatches.isNotEmpty)
                  SliverToBoxAdapter(child: MatchesList(matches: newMatches)),

                if (newMatches.isNotEmpty && activeConversations.isNotEmpty)
                  const SliverToBoxAdapter(child: Divider(height: 1)),

                // Active Conversations
                if (activeConversations.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final conversation = activeConversations[index];
                      final otherUserId = conversation.getOtherParticipantId(
                        currentUser?.uid ?? '',
                      );

                      return Column(
                        children: [
                          ConversationItem(
                            conversation: conversation,
                            otherUserId: otherUserId,
                            currentUserId: currentUser?.uid ?? '',
                            onTap: () {
                              context.push('/chat/${conversation.id}');
                            },
                            onDelete: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Eliminar conversación'),
                                  content: const Text(
                                    '¿Estás seguro de que quieres eliminar esta conversación?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                await ref
                                    .read(conversationsProvider.notifier)
                                    .deleteConversation(conversation.id);
                              }
                            },
                          ),
                          if (index < activeConversations.length - 1)
                            const Divider(height: 1, indent: 88),
                        ],
                      );
                    }, childCount: activeConversations.length),
                  )
                else if (newMatches.isNotEmpty)
                  // Show message if only matches but no conversations
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.messageSquare,
                              size: 48,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Inicia una conversación',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
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
                'Error al cargar conversaciones',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.messageCircle,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'No tienes conversaciones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Haz match con alguien para empezar a chatear',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
