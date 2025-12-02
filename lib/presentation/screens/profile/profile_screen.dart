import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../../core/services/seed_data_service.dart';
import '../../widgets/gradient_button.dart';

final seedDataServiceProvider = Provider<SeedDataService>(
  (ref) => SeedDataService(),
);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: () {
              // TODO: Ir a configuración
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      image: currentUser?.photoURL != null
                          ? DecorationImage(
                              image: NetworkImage(currentUser!.photoURL!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: currentUser?.photoURL == null
                        ? const Icon(
                            LucideIcons.user,
                            size: 60,
                            color: AppColors.textSecondary,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.camera,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Email
            Text(
              currentUser?.email ?? '',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 48),

            // Opciones
            _buildProfileOption(
              icon: LucideIcons.edit,
              title: 'Editar Perfil',
              onTap: () => context.push('/edit-profile'),
            ),
            _buildProfileOption(
              icon: LucideIcons.heart,
              title: 'Mis Likes',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: LucideIcons.shield,
              title: 'Privacidad',
              onTap: () {},
            ),

            const SizedBox(height: 48),

            // Seed Data Button (Temporary)
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  try {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sembrando datos... 🌱')),
                    );

                    await ref.read(seedDataServiceProvider).seedUsers();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('¡Datos sembrados con éxito! ✅'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                icon: const Icon(
                  LucideIcons.database,
                  color: AppColors.primary,
                ),
                label: const Text(
                  'Sembrar Datos de Prueba',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Cerrar Sesión
            GradientButton(
              text: 'Cerrar Sesión',
              onPressed: () async {
                await ref.read(authServiceProvider).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              icon: LucideIcons.logOut,
              // Usar un color diferente para logout si se desea
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          LucideIcons.chevronRight,
          color: AppColors.textSecondary,
          size: 20,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
