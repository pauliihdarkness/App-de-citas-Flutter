import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme.dart';
import '../../widgets/gradient_button.dart';
import '../../../data/models/interest_model.dart';
import '../../../core/services/interests_service.dart';

class EditInterestsModal extends StatefulWidget {
  final List<Interest> selectedInterests;

  const EditInterestsModal({super.key, required this.selectedInterests});

  @override
  State<EditInterestsModal> createState() => _EditInterestsModalState();
}

class _EditInterestsModalState extends State<EditInterestsModal> {
  late List<Interest> _selectedInterests;
  Map<String, List<Interest>> _interestsByCategory = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedInterests = List.from(widget.selectedInterests);
    _loadInterests();
  }

  Future<void> _loadInterests() async {
    try {
      await InterestsService.instance.loadInterests();
      setState(() {
        _interestsByCategory = InterestsService.instance
            .getInterestsByCategory();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading interests: $e');
      setState(() => _isLoading = false);
    }
  }

  void _toggleInterest(Interest interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        if (_selectedInterests.length < 8) {
          _selectedInterests.add(interest);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Máximo 8 intereses')));
        }
      }
    });
  }

  void _handleSave() {
    context.pop(_selectedInterests);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Intereses',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${_selectedInterests.length}/8 seleccionados',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(LucideIcons.x, color: AppColors.textSecondary),
                onPressed: () => context.pop(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _interestsByCategory.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: entry.value.map((interest) {
                                final isSelected = _selectedInterests.contains(
                                  interest,
                                );
                                return FilterChip(
                                  label: Text(interest.displayName),
                                  selected: isSelected,
                                  onSelected: (_) => _toggleInterest(interest),
                                  selectedColor: AppColors.primary.withOpacity(
                                    0.2,
                                  ),
                                  checkmarkColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  backgroundColor: AppColors.glassBg,
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
          const SizedBox(height: 24),
          GradientButton(text: 'Guardar', onPressed: _handleSave),
        ],
      ),
    );
  }
}
