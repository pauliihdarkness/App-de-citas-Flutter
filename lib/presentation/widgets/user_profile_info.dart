import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/theme.dart';
import '../../data/models/user_model.dart';

class UserProfileInfo extends StatelessWidget {
  final UserModel user;

  const UserProfileInfo({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name, Age
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
              // Verification badge
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
              _buildInfoRow(LucideIcons.briefcase, user.job.title),
            if (user.job.company.isNotEmpty)
              _buildInfoRow(LucideIcons.building, user.job.company),
            if (user.job.education.isNotEmpty)
              _buildInfoRow(LucideIcons.graduationCap, user.job.education),
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
            _buildInfoRow(LucideIcons.ruler, '${user.lifestyle.height} cm'),
          if (user.lifestyle.workout.isNotEmpty)
            _buildInfoRow(LucideIcons.dumbbell, user.lifestyle.workout),
          if (user.lifestyle.drink.isNotEmpty)
            _buildInfoRow(LucideIcons.wine, user.lifestyle.drink),
          if (user.lifestyle.smoke.isNotEmpty)
            _buildInfoRow(LucideIcons.cigarette, user.lifestyle.smoke),
          if (user.lifestyle.zodiac.isNotEmpty)
            _buildInfoRow(LucideIcons.sparkles, user.lifestyle.zodiac),

          const SizedBox(height: 100), // Space for bottom
        ],
      ),
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
