import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/modals/edit_account_info_modal.dart';
import '../../widgets/modals/edit_security_modal.dart';
import '../../widgets/modals/edit_location_modal.dart';

/// Pantalla de Configuración
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      LucideIcons.arrowLeft,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Configuración',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Settings List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Cuenta
                  _buildSectionHeader('Cuenta'),
                  _buildSettingsTile(
                    icon: LucideIcons.user,
                    title: 'Info de Cuenta',
                    subtitle: 'Nombre, género, orientación',
                    onTap: () => _openAccountInfoModal(context),
                  ),
                  _buildSettingsTile(
                    icon: LucideIcons.shield,
                    title: 'Seguridad',
                    subtitle: 'Email, contraseña, eliminar cuenta',
                    onTap: () => _openSecurityModal(context),
                  ),

                  const SizedBox(height: 24),

                  // Preferencias
                  _buildSectionHeader('Preferencias de Búsqueda'),
                  _buildSettingsTile(
                    icon: LucideIcons.sliders,
                    title: 'Filtros de Búsqueda',
                    subtitle: 'Edad, distancia, género',
                    onTap: () {
                      // TODO: Navegar a pantalla de filtros
                    },
                  ),
                  _buildSettingsTile(
                    icon: LucideIcons.mapPin,
                    title: 'Ubicación',
                    subtitle: 'Actualizar ubicación',
                    onTap: () => _openLocationModal(context),
                  ),

                  const SizedBox(height: 24),

                  // Notificaciones
                  _buildSectionHeader('Notificaciones'),
                  _buildSettingsTile(
                    icon: LucideIcons.bell,
                    title: 'Notificaciones Push',
                    subtitle: 'Matches, mensajes, likes',
                    onTap: () {
                      // TODO: Navegar a pantalla de notificaciones
                    },
                  ),

                  const SizedBox(height: 24),

                  // Privacidad
                  _buildSectionHeader('Privacidad'),
                  _buildSettingsTile(
                    icon: LucideIcons.eye,
                    title: 'Privacidad',
                    subtitle: 'Controla quién puede verte',
                    onTap: () {
                      // TODO: Navegar a pantalla de privacidad
                    },
                  ),
                  _buildSettingsTile(
                    icon: LucideIcons.userX,
                    title: 'Usuarios Bloqueados',
                    onTap: () {
                      // TODO: Navegar a pantalla de bloqueados
                    },
                  ),

                  const SizedBox(height: 24),

                  // Soporte
                  _buildSectionHeader('Soporte'),
                  _buildSettingsTile(
                    icon: LucideIcons.helpCircle,
                    title: 'Centro de Ayuda',
                    onTap: () {
                      // TODO: Navegar a centro de ayuda
                    },
                  ),
                  _buildSettingsTile(
                    icon: LucideIcons.fileText,
                    title: 'Términos y Condiciones',
                    onTap: () {
                      // TODO: Navegar a términos
                    },
                  ),
                  _buildSettingsTile(
                    icon: LucideIcons.lock,
                    title: 'Política de Privacidad',
                    onTap: () {
                      // TODO: Navegar a política
                    },
                  ),

                  const SizedBox(height: 24),

                  // Cerrar Sesión
                  _buildSettingsTile(
                    icon: LucideIcons.logOut,
                    title: 'Cerrar Sesión',
                    titleColor: Colors.orange,
                    onTap: () => _showLogoutDialog(context, ref),
                  ),

                  const SizedBox(height: 32),

                  // Versión
                  Center(
                    child: Text(
                      'Versión 1.0.0',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAccountInfoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EditAccountInfoModal(),
    );
  }

  void _openSecurityModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EditSecurityModal(),
    );
  }

  void _openLocationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EditLocationModal(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: titleColor ?? AppColors.textPrimary,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              )
            : null,
        trailing: const Icon(
          LucideIcons.chevronRight,
          color: AppColors.textSecondary,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          '¿Cerrar sesión?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}
