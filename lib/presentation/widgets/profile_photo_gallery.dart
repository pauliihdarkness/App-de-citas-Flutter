import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/theme.dart';

class ProfilePhotoGallery extends StatefulWidget {
  final List<String> photos;
  final VoidCallback? onEditTap;
  final bool showEditButton;

  const ProfilePhotoGallery({
    super.key,
    required this.photos,
    this.onEditTap,
    this.showEditButton = false,
  });

  @override
  State<ProfilePhotoGallery> createState() => _ProfilePhotoGalleryState();
}

class _ProfilePhotoGalleryState extends State<ProfilePhotoGallery> {
  int _currentPhotoIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Photo
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Image.network(
            widget.photos[_currentPhotoIndex],
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

        // Tap Zones
        if (widget.photos.length > 1)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (_currentPhotoIndex > 0) {
                      setState(() => _currentPhotoIndex--);
                    }
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (_currentPhotoIndex < widget.photos.length - 1) {
                      setState(() => _currentPhotoIndex++);
                    }
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),
            ],
          ),

        // Indicators
        if (widget.photos.length > 1)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: widget.showEditButton ? 64 : 16,
            child: Row(
              children: List.generate(
                widget.photos.length,
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

        // Gradient Overlay at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.background],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
