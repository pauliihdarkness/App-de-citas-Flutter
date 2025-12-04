import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme.dart';
import '../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/profile_photo_gallery.dart';
import '../../widgets/user_profile_info.dart';

class UserDetailScreen extends ConsumerStatefulWidget {
  final String userId;
  final bool hideActions;

  const UserDetailScreen({
    super.key,
    required this.userId,
    this.hideActions = false,
  });

  @override
  ConsumerState<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends ConsumerState<UserDetailScreen> {
  Future<void> _handleLike(UserModel user) async {
    final currentUserId = ref.read(currentUserProvider)!.uid;
    final isMatch = await ref
        .read(firestoreServiceProvider)
        .recordLike(currentUserId, user.uid, 'like');

    if (isMatch && mounted) {
      _showMatchDialog(user);
    } else if (mounted && context.canPop()) {
      // Return 'like' action to trigger swipe in HomeScreen
      context.pop('like');
    }
  }

  Future<void> _handlePass(UserModel user) async {
    final currentUserId = ref.read(currentUserProvider)!.uid;
    await ref
        .read(firestoreServiceProvider)
        .recordLike(currentUserId, user.uid, 'pass');

    if (mounted && context.canPop()) {
      // Return 'pass' action to trigger swipe in HomeScreen
      context.pop('pass');
    }
  }

  void _showMatchDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.heart, color: Colors.white, size: 60),
              const SizedBox(height: 16),
              const Text(
                "It's a Match!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Tú y ${user.name} se gustan.",
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.pop(); // Close dialog
                      if (context.canPop()) {
                        context.pop('like'); // Go back to feed with result
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text('Seguir'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.pop(); // Close dialog
                      if (context.canPop()) {
                        context.pop('like'); // Go back to feed with result
                      }
                      // TODO: Navigate to chat
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text('Chat'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(
      firestoreServiceProvider.select(
        (service) => service.getUser(widget.userId),
      ),
    );

    return FutureBuilder<UserModel?>(
      future: userAsync,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(backgroundColor: AppColors.background),
            body: const Center(child: Text('Usuario no encontrado')),
          );
        }

        final user = snapshot.data!;
        final photos = user.photos.isNotEmpty
            ? user.photos
            : ['https://via.placeholder.com/400x600?text=No+Photo'];

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // Main scrollable content
              SingleChildScrollView(
                child: Column(
                  children: [
                    // Photo Gallery
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: ProfilePhotoGallery(photos: photos),
                    ),

                    // User Info
                    UserProfileInfo(user: user),
                  ],
                ),
              ),

              // Back Button
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      LucideIcons.arrowLeft,
                      color: Colors.white,
                    ),
                    onPressed: () => context.pop(),
                  ),
                ),
              ),
            ],
          ),

          // Action Buttons
          bottomNavigationBar: widget.hideActions
              ? null
              : Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Pass Button
                      ActionButton(
                        icon: LucideIcons.x,
                        color: Colors.red,
                        size: 70,
                        onPressed: () => _handlePass(user),
                      ),
                      // Like Button
                      ActionButton(
                        icon: LucideIcons.heart,
                        color: AppColors.primary,
                        size: 70,
                        onPressed: () => _handleLike(user),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
