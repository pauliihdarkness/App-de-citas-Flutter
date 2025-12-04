import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/theme.dart';
import '../../data/models/user_model.dart';
import '../widgets/gradient_button.dart';

class MatchDialog extends StatefulWidget {
  final UserModel matchedUser;
  final UserModel currentUser;

  const MatchDialog({
    super.key,
    required this.matchedUser,
    required this.currentUser,
  });

  @override
  State<MatchDialog> createState() => _MatchDialogState();
}

class _MatchDialogState extends State<MatchDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.primary.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            SlideTransition(
              position: _slideAnimation,
              child: const Text(
                "It's a Match!",
                style: TextStyle(
                  fontFamily: 'Cursive', // O una fuente display llamativa
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  shadows: [
                    Shadow(
                      color: AppColors.secondary,
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Avatars
            ScaleTransition(
              scale: _scaleAnimation,
              child: SizedBox(
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Left Avatar (Current User)
                    Positioned(
                      left: 20,
                      child: Transform.rotate(
                        angle: -0.2,
                        child: _buildAvatar(
                          widget.currentUser.photos.firstOrNull,
                        ),
                      ),
                    ),
                    // Right Avatar (Matched User)
                    Positioned(
                      right: 20,
                      child: Transform.rotate(
                        angle: 0.2,
                        child: _buildAvatar(
                          widget.matchedUser.photos.firstOrNull,
                        ),
                      ),
                    ),
                    // Heart Icon
                    Positioned(
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.heart,
                          color: AppColors.primary,
                          size: 32,
                          fill:
                              1.0, // Relleno sólido si es soportado por el icono
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Description
            FadeTransition(
              opacity: _controller,
              child: Text(
                "Tú y ${widget.matchedUser.name} se gustan mutuamente.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Buttons
            SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  GradientButton(
                    text: 'Enviar Mensaje',
                    icon: LucideIcons.messageCircle,
                    onPressed: () {
                      context.pop(); // Cerrar dialog

                      // Generar ID de conversación (determinista: ids ordenados)
                      final ids = [
                        widget.currentUser.uid,
                        widget.matchedUser.uid,
                      ]..sort();
                      final conversationId = '${ids[0]}_${ids[1]}';

                      context.push('/chat/$conversationId');
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white54,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'Seguir Deslizando',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String? photoUrl) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        image: photoUrl != null
            ? DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover)
            : null,
      ),
      child: photoUrl == null
          ? const Icon(
              LucideIcons.user,
              size: 40,
              color: AppColors.textSecondary,
            )
          : null,
    );
  }
}
