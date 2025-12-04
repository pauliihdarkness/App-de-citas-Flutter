import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme.dart';
import '../home/home_screen.dart';
import '../likes/likes_screen.dart';
import '../chat/conversations_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications/notifications_screen.dart';

/// Provider para el índice de la tab activa
final currentTabIndexProvider = StateProvider<int>((ref) => 0);

/// Scaffold principal con Bottom Navigation Bar
class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentTabIndexProvider);

    // Lista de pantallas
    final screens = [
      const HomeScreen(), // Descubrir
      const LikesScreen(), // Likes
      const ConversationsScreen(), // Matches/Chat
      const NotificationsScreen(), // Notificaciones
      ProfileScreen(), // Perfil (sin const para asegurar refresh)
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  ref: ref,
                  index: 0,
                  icon: LucideIcons.compass,
                  label: 'Descubrir',
                  isActive: currentIndex == 0,
                ),
                _buildNavItem(
                  context: context,
                  ref: ref,
                  index: 1,
                  icon: LucideIcons.star,
                  label: 'Likes',
                  isActive: currentIndex == 1,
                ),
                _buildNavItem(
                  context: context,
                  ref: ref,
                  index: 2,
                  icon: LucideIcons.messageCircle,
                  label: 'Chat',
                  isActive: currentIndex == 2,
                  // TODO: Agregar badge con contador de mensajes no leídos
                ),
                _buildNavItem(
                  context: context,
                  ref: ref,
                  index: 3,
                  icon: LucideIcons.bell,
                  label: 'Avisos',
                  isActive: currentIndex == 3,
                  // TODO: Agregar badge con contador de notificaciones no leídas
                ),
                _buildNavItem(
                  context: context,
                  ref: ref,
                  index: 4,
                  icon: LucideIcons.user,
                  label: 'Perfil',
                  isActive: currentIndex == 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required WidgetRef ref,
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
    int? badgeCount,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          ref.read(currentTabIndexProvider.notifier).state = index;
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Indicador superior para tab activa
            Container(
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      )
                    : null,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            // Icono con badge opcional
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                  size: 24,
                ),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // Label
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
