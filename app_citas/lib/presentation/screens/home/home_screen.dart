import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme.dart';
import '../../widgets/profile_card.dart';
import '../../widgets/action_button.dart';
import '../../providers/users_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../data/models/user_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final AppinioSwiperController _swiperController = AppinioSwiperController();

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  Future<void> _handleSwipe(
    int previousIndex,
    int? currentIndex,
    SwiperActivity activity,
    List<UserModel> users,
  ) async {
    final direction = activity.direction;
    final user = users[previousIndex];

    if (direction == AxisDirection.right) {
      print('❤️ Like: Usuario ${user.name}');
      final isMatch = await ref
          .read(firestoreServiceProvider)
          .recordLike(ref.read(currentUserProvider)!.uid, user.uid, 'like');

      if (isMatch && mounted) {
        _showMatchDialog(context, user);
      }
    } else if (direction == AxisDirection.left) {
      print('👎 Dislike: Usuario ${user.name}');
      ref
          .read(firestoreServiceProvider)
          .recordLike(ref.read(currentUserProvider)!.uid, user.uid, 'pass');
    }
  }

  void _showMatchDialog(BuildContext context, UserModel user) {
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
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Seguir'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.pop();
                      // TODO: Ir al chat
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
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
    final users = ref.watch(usersProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ).createShader(bounds),
                    child: const Icon(
                      LucideIcons.heart,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),

                  // User info
                  InkWell(
                    onTap: () => context.push('/profile'),
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      children: [
                        Text(
                          currentUser?.displayName?.split(' ')[0] ?? 'Usuario',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: currentUser?.photoURL != null
                              ? NetworkImage(currentUser!.photoURL!)
                              : null,
                          child: currentUser?.photoURL == null
                              ? const Icon(LucideIcons.user, size: 20)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Swipe Cards
            Expanded(
              child: users.when(
                data: (userList) {
                  if (userList.isEmpty) return _buildEmptyState();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AppinioSwiper(
                      controller: _swiperController,
                      cardCount: userList.length,
                      cardBuilder: (context, index) {
                        return ProfileCard(
                          user: userList[index],
                          onLike: () {},
                          onPass: () {},
                        );
                      },
                      onSwipeEnd: (previousIndex, currentIndex, activity) =>
                          _handleSwipe(
                            previousIndex,
                            currentIndex,
                            activity,
                            userList,
                          ),
                      maxAngle: 30,
                      threshold: 50,
                      onEnd: () {
                        // Cuando se acaban las tarjetas
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),

            // Action Buttons
            if (users.hasValue && users.value!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Dislike
                    ActionButton(
                      icon: LucideIcons.x,
                      color: Colors.red,
                      size: 70,
                      onPressed: () {
                        _swiperController.swipeLeft();
                      },
                    ),

                    // Like
                    ActionButton(
                      icon: LucideIcons.heart,
                      color: AppColors.primary,
                      size: 70,
                      onPressed: () {
                        _swiperController.swipeRight();
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.2),
                  AppColors.secondary.withOpacity(0.2),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.users,
              size: 60,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No hay más usuarios',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vuelve más tarde para ver nuevos perfiles',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
