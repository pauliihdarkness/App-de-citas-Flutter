import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/theme.dart';
import '../../data/models/user_model.dart';

class ProfileCard extends StatefulWidget {
  final UserModel user;
  final VoidCallback onLike;
  final VoidCallback onPass;

  const ProfileCard({
    super.key,
    required this.user,
    required this.onLike,
    required this.onPass,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  int _currentPhotoIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.user.photos.isNotEmpty
        ? widget.user.photos
        : ['https://via.placeholder.com/400x600?text=No+Photo'];

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Photo Carousel
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPhotoIndex = index);
              },
              itemCount: photos.length,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe
              itemBuilder: (context, index) {
                return Image.network(
                  photos[index],
                  fit: BoxFit.cover,
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
                );
              },
            ),

            // Tap zones for navigation (only if multiple photos)
            if (photos.length > 1)
              Row(
                children: [
                  // Left tap zone - Previous photo
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_currentPhotoIndex > 0) {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  // Right tap zone - Next photo
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_currentPhotoIndex < photos.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ],
              ),

            // Gradient Overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
              ),
            ),

            // Photo Indicators
            if (photos.length > 1)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  children: List.generate(
                    photos.length,
                    (index) => Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
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

            // User Info
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Age
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${widget.user.name}, ${widget.user.age}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 4),
                            ],
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
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.shieldAlert,
                          size: 18,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Info button
                      GestureDetector(
                        onTap: () async {
                          final result = await context.push(
                            '/user/${widget.user.uid}',
                          );

                          // Handle the result from UserDetailScreen
                          if (result == 'like' && context.mounted) {
                            widget.onLike();
                          } else if (result == 'pass' && context.mounted) {
                            widget.onPass();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.info,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Bio Preview
                  if (widget.user.bio.isNotEmpty)
                    Text(
                      widget.user.bio,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
