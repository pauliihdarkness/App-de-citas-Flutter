import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme.dart';
import '../../../data/models/conversation_model.dart';
import '../../providers/users_provider.dart';
import '../../providers/auth_provider.dart';

class MatchesList extends ConsumerWidget {
  final List<ConversationModel> matches;

  const MatchesList({super.key, required this.matches});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    if (matches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Nuevos Matches',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 110,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                final otherUserId = match.getOtherParticipantId(
                  currentUser?.uid ?? '',
                );

                return _MatchItem(
                  match: match,
                  otherUserId: otherUserId,
                  onTap: () => context.push('/chat/${match.id}'),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _MatchItem extends ConsumerWidget {
  final ConversationModel match;
  final String otherUserId;
  final VoidCallback onTap;

  const _MatchItem({
    required this.match,
    required this.otherUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otherUserAsync = ref.watch(userByIdProvider(otherUserId));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: otherUserAsync.when(
                data: (user) {
                  if (user == null) {
                    return const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.glassBg,
                      child: Icon(
                        LucideIcons.user,
                        color: AppColors.textSecondary,
                      ),
                    );
                  }
                  return CircleAvatar(
                    radius: 30,
                    backgroundImage: user.photos.isNotEmpty
                        ? NetworkImage(user.photos.first)
                        : null,
                    child: user.photos.isEmpty
                        ? const Icon(LucideIcons.user)
                        : null,
                  );
                },
                loading: () => const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.glassBg,
                ),
                error: (_, __) => const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.glassBg,
                  child: Icon(LucideIcons.user),
                ),
              ),
            ),
            const SizedBox(height: 6),
            otherUserAsync.when(
              data: (user) => Text(
                user?.name ?? 'Usuario',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              loading: () => const SizedBox(height: 12),
              error: (_, __) => const SizedBox(height: 12),
            ),
          ],
        ),
      ),
    );
  }
}
