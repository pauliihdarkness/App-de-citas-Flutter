import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme.dart';
import '../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/action_button.dart';

class UserDetailScreen extends ConsumerStatefulWidget {
  final String userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  ConsumerState<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends ConsumerState<UserDetailScreen> {
  int _currentPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentPhotoIndex = 0;
  }

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
                      child: Stack(
                        children: [
                          // Current Photo with Smooth Transition
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            switchInCurve: Curves.easeInOutCubic,
                            switchOutCurve: Curves.easeInOutCubic,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(0.3, 0.0),
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutCubic,
                                        ),
                                      ),
                                  child: child,
                                ),
                              );
                            },
                            child: Image.network(
                              photos[_currentPhotoIndex],
                              key: ValueKey(_currentPhotoIndex),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.cardBg,
                                  child: const Center(
                                    child: Icon(
                                      LucideIcons.user,
                                      size: 100,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Tap zones (only if multiple photos)
                          if (photos.length > 1)
                            Row(
                              children: [
                                // Left tap zone
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      if (_currentPhotoIndex > 0) {
                                        setState(() {
                                          _currentPhotoIndex--;
                                        });
                                      }
                                    },
                                    child: Container(color: Colors.transparent),
                                  ),
                                ),
                                // Right tap zone
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      if (_currentPhotoIndex <
                                          photos.length - 1) {
                                        setState(() {
                                          _currentPhotoIndex++;
                                        });
                                      }
                                    },
                                    child: Container(color: Colors.transparent),
                                  ),
                                ),
                              ],
                            ),

                          // Photo Indicators
                          if (photos.length > 1)
                            Positioned(
                              top: MediaQuery.of(context).padding.top + 16,
                              left: 16,
                              right: 16,
                              child: Row(
                                children: List.generate(
                                  photos.length,
                                  (index) => Expanded(
                                    child: Container(
                                      height: 4,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _currentPhotoIndex == index
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),
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
                    ),

                    // User Info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name, Age and Verification Badge
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${user.name}, ${user.age}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Verification badge (not verified)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  LucideIcons.shieldAlert,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Location
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.mapPin,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${user.location.city}, ${user.location.state}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Bio
                          if (user.bio.isNotEmpty) ...[
                            const Text(
                              'Sobre mí',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              user.bio,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Interests
                          if (user.interests.isNotEmpty) ...[
                            const Text(
                              'Intereses',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: user.interests.map((interest) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    interest,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Job & Education
                          if (user.job.title.isNotEmpty ||
                              user.job.company.isNotEmpty ||
                              user.job.education.isNotEmpty) ...[
                            const Text(
                              'Trabajo y Educación',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (user.job.title.isNotEmpty)
                              _buildInfoRow(
                                LucideIcons.briefcase,
                                user.job.title,
                              ),
                            if (user.job.company.isNotEmpty)
                              _buildInfoRow(
                                LucideIcons.building,
                                user.job.company,
                              ),
                            if (user.job.education.isNotEmpty)
                              _buildInfoRow(
                                LucideIcons.graduationCap,
                                user.job.education,
                              ),
                            const SizedBox(height: 24),
                          ],

                          // Lifestyle
                          const Text(
                            'Estilo de Vida',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (user.lifestyle.height.isNotEmpty)
                            _buildInfoRow(
                              LucideIcons.ruler,
                              '${user.lifestyle.height} cm',
                            ),
                          if (user.lifestyle.workout.isNotEmpty)
                            _buildInfoRow(
                              LucideIcons.dumbbell,
                              user.lifestyle.workout,
                            ),
                          if (user.lifestyle.drink.isNotEmpty)
                            _buildInfoRow(
                              LucideIcons.wine,
                              user.lifestyle.drink,
                            ),
                          if (user.lifestyle.smoke.isNotEmpty)
                            _buildInfoRow(
                              LucideIcons.cigarette,
                              user.lifestyle.smoke,
                            ),

                          const SizedBox(height: 100), // Space for buttons
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Action Buttons - Using ActionButton widget
          bottomNavigationBar: Container(
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
