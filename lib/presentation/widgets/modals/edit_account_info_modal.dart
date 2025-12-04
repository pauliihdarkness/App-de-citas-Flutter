import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/custom_input.dart';
import '../../providers/auth_provider.dart';
import '../../../data/models/user_model.dart';

class EditAccountInfoModal extends ConsumerStatefulWidget {
  const EditAccountInfoModal({super.key});

  @override
  ConsumerState<EditAccountInfoModal> createState() =>
      _EditAccountInfoModalState();
}

class _EditAccountInfoModalState extends ConsumerState<EditAccountInfoModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String? _selectedGender;
  String? _selectedOrientation;
  bool _isLoading = false;

  final List<String> _genders = [
    'Hombre',
    'Mujer',
    'No binario',
    'Género fluido',
    'Agénero',
    'Otro',
    'Prefiero no decir',
  ];

  final List<String> _orientations = [
    'Heterosexual',
    'Gay',
    'Lesbiana',
    'Bisexual',
    'Pansexual',
    'Asexual',
    'Demisexual',
    'Queer',
    'Otro',
    'Prefiero no decir',
  ];

  @override
  void initState() {
    super.initState();
    final userProfile = ref.read(userProfileProvider).value;
    _nameController = TextEditingController(text: userProfile?.name ?? '');
    _selectedGender = userProfile?.gender;
    _selectedOrientation = userProfile?.sexualOrientation;

    // Ensure initial values are in the list, otherwise default to 'Prefiero no decir' or add them
    if (_selectedGender != null && !_genders.contains(_selectedGender)) {
      if (_selectedGender!.isNotEmpty) {
        _genders.add(_selectedGender!);
      } else {
        _selectedGender = 'Prefiero no decir';
      }
    }
    if (_selectedOrientation != null &&
        !_orientations.contains(_selectedOrientation)) {
      if (_selectedOrientation!.isNotEmpty) {
        _orientations.add(_selectedOrientation!);
      } else {
        _selectedOrientation = 'Prefiero no decir';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final currentProfile = ref.read(userProfileProvider).value;

      if (currentProfile == null) return;

      final updatedProfile = UserModel(
        id: currentProfile.id,
        uid: currentProfile.uid,
        name: _nameController.text.trim(),
        age: currentProfile.age,
        bio: currentProfile.bio,
        photos: currentProfile.photos,
        location: currentProfile.location,
        distance: currentProfile.distance,
        interests: currentProfile.interests,
        gender: _selectedGender ?? 'Prefiero no decir',
        sexualOrientation: _selectedOrientation ?? 'Prefiero no decir',
        job: currentProfile.job,
        lifestyle: currentProfile.lifestyle,
        searchIntent: currentProfile.searchIntent,
        active: currentProfile.active,
        createdAt: currentProfile.createdAt,
        updatedAt: DateTime.now(),
      );

      await firestoreService.updateUserProfile(updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Información actualizada')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Info de Cuenta',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    LucideIcons.x,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => context.pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomInput(
                      label: 'Nombre',
                      hint: 'Tu nombre',
                      icon: LucideIcons.user,
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildDropdown(
                      label: 'Género',
                      value: _selectedGender,
                      items: _genders,
                      onChanged: (value) =>
                          setState(() => _selectedGender = value),
                      icon: LucideIcons.users,
                    ),
                    const SizedBox(height: 24),
                    _buildDropdown(
                      label: 'Orientación Sexual',
                      value: _selectedOrientation,
                      items: _orientations,
                      onChanged: (value) =>
                          setState(() => _selectedOrientation = value),
                      icon: LucideIcons.heart,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: 'Guardar',
              onPressed: _handleSave,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    dropdownColor: AppColors.surface,
                    icon: const Icon(
                      LucideIcons.chevronDown,
                      color: AppColors.textSecondary,
                    ),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                    items: items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
