import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PhotoItem extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onRemove;
  final VoidCallback? onAdd;
  final bool isLoading;
  final double? progress;
  final bool isPlaceholder;

  const PhotoItem({
    super.key,
    this.imageUrl,
    this.onRemove,
    this.onAdd,
    this.isLoading = false,
    this.progress,
    this.isPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: isPlaceholder
            ? Border.all(
                color: const Color(0xFFE94057).withOpacity(0.5),
                width: 2,
                style: BorderStyle.solid,
              )
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen o Placeholder
          if (imageUrl != null)
            CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFE94057),
                ),
              ),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.error_outline, color: Colors.red),
            )
          else if (isPlaceholder)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAdd,
                child: const Center(
                  child: Icon(
                    Icons.add_rounded,
                    color: Color(0xFFE94057),
                    size: 32,
                  ),
                ),
              ),
            ),

          // Loading Overlay
          if (isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                    if (progress != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${(progress! * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // Remove Button
          if (imageUrl != null && !isLoading && onRemove != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ).animate().scale(duration: 200.ms, curve: Curves.easeOut),
        ],
      ),
    );
  }
}
