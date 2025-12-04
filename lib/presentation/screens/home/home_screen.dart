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
import '../../widgets/match_dialog.dart';

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
    final currentUser = ref.read(currentUserProvider);
    final userProfile = ref.read(userProfileProvider).value;

    if (currentUser == null) return;

    // Usar fotos del perfil de Firestore si existen, sino usar la de Auth
    final List<String> photos = [];
    if (userProfile != null && userProfile.photos.isNotEmpty) {
      photos.addAll(userProfile.photos);
    } else if (currentUser.photoURL != null) {
      photos.add(currentUser.photoURL!);
    }

    final currentUserModel = UserModel(
      id: currentUser.uid,
      uid: currentUser.uid,
      name: userProfile?.name ?? currentUser.displayName ?? 'Yo',
      age: userProfile?.age ?? 0,
      bio: userProfile?.bio ?? '',
      photos: photos,
      location: UserLocation(country: '', state: '', city: ''),
      gender: '',
      sexualOrientation: '',
      job: UserJob(title: '', company: '', education: ''),
      lifestyle: UserLifestyle(
        drink: '',
        smoke: '',
        workout: '',
        zodiac: '',
        height: '',
      ),
      searchIntent: '',
    );

    showDialog(
      context: context,
      builder: (context) =>
          MatchDialog(matchedUser: user, currentUser: currentUserModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 320;
    final horizontalPadding = isSmallScreen ? 8.0 : 16.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                ],
              ),
            ),

            // Swipe Cards
            Expanded(
              child: users.when(
                data: (userList) {
                  if (userList.isEmpty) return _buildEmptyState();
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
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
                padding: EdgeInsets.all(isSmallScreen ? 12 : 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Dislike
                    ActionButton(
                      icon: LucideIcons.x,
                      color: Colors.red,
                      size: isSmallScreen ? 50 : 70,
                      onPressed: () {
                        _swiperController.swipeLeft();
                      },
                    ),

                    // Like
                    ActionButton(
                      icon: LucideIcons.heart,
                      color: AppColors.primary,
                      size: isSmallScreen ? 50 : 70,
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
