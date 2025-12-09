import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../../core/services/seed_data_service.dart';
import '../../widgets/profile_photo_gallery.dart';
import '../../widgets/user_profile_info.dart';
import '../../widgets/booster_promo_modal.dart';

final seedDataServiceProvider = Provider<SeedDataService>(
  (ref) => SeedDataService(),
);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: userProfileAsync.when(
        data: (userProfile) {
          if (userProfile == null) {
            return const Center(
              child: Text(
                'No se pudo cargar el perfil',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          final photos = userProfile.photos.isNotEmpty
              ? userProfile.photos
              : ['https://via.placeholder.com/400x600?text=No+Photo'];

          return Stack(
            children: [
              // Main scrollable content
              SingleChildScrollView(
                child: Column(
                  children: [
                    // Photo Gallery
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: ProfilePhotoGallery(
                        photos: photos,
                        showEditButton: true, // Para ajustar los indicadores
                        onEditTap: () => context.push('/edit-profile'),
                      ),
                    ),

                    // User Info
                    UserProfileInfo(user: userProfile),
                  ],
                ),
              ),

              // Floating Boost Button
              Positioned(
                bottom: 90,
                right: 24,
                child: FloatingActionButton(
                  heroTag: 'boost_button',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const BoosterPromoModal(),
                    );
                  },
                  backgroundColor: AppColors.secondary,
                  child: const Icon(LucideIcons.zap, color: Colors.white),
                ),
              ),

              // Floating Edit Button
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton.extended(
                  onPressed: () => context.push('/edit-profile'),
                  backgroundColor: AppColors.primary,
                  icon: const Icon(LucideIcons.edit, color: Colors.white),
                  label: const Text(
                    'Editar Perfil',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Settings Button (Top Right)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(LucideIcons.settings, color: Colors.white),
                    onPressed: () => context.push('/settings'),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
