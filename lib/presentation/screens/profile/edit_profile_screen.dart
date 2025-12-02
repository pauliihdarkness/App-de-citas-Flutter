import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/gradient_button.dart';
import '../../providers/auth_provider.dart';
import '../../../data/models/user_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bioController;
  late TextEditingController _jobTitleController;
  late TextEditingController _jobCompanyController;
  late TextEditingController _jobEducationController;
  late TextEditingController _heightController;

  // Lifestyle values
  String _drink = 'Prefiero no decir';
  String _smoke = 'Prefiero no decir';
  String _workout = 'Prefiero no decir';
  String _zodiac = 'Aries';
  String _searchIntent = 'No lo sé aún';

  // Interests
  List<String> _selectedInterests = [];
  final List<String> _availableInterests = [
    'Música',
    'Viajes',
    'Deportes',
    'Cine',
    'Lectura',
    'Cocina',
    'Arte',
    'Tecnología',
    'Videojuegos',
    'Fotografía',
    'Baile',
    'Animales',
    'Naturaleza',
    'Moda',
    'Política',
    'Voluntariado',
  ];

  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController();
    _jobTitleController = TextEditingController();
    _jobCompanyController = TextEditingController();
    _jobEducationController = TextEditingController();
    _heightController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadUserData();
      _isInitialized = true;
    }
  }

  void _loadUserData() {
    final userProfile = ref.read(userProfileProvider).value;
    if (userProfile != null) {
      _bioController.text = userProfile.bio;
      _jobTitleController.text = userProfile.job.title;
      _jobCompanyController.text = userProfile.job.company;
      _jobEducationController.text = userProfile.job.education;
      _heightController.text = userProfile.lifestyle.height;

      setState(() {
        _drink = userProfile.lifestyle.drink.isNotEmpty
            ? userProfile.lifestyle.drink
            : 'Prefiero no decir';
        _smoke = userProfile.lifestyle.smoke.isNotEmpty
            ? userProfile.lifestyle.smoke
            : 'Prefiero no decir';
        _workout = userProfile.lifestyle.workout.isNotEmpty
            ? userProfile.lifestyle.workout
            : 'Prefiero no decir';
        _zodiac = userProfile.lifestyle.zodiac.isNotEmpty
            ? userProfile.lifestyle.zodiac
            : 'Aries';
        _searchIntent = userProfile.searchIntent.isNotEmpty
            ? userProfile.searchIntent
            : 'No lo sé aún';
        _selectedInterests = List.from(userProfile.interests);
      });
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _jobTitleController.dispose();
    _jobCompanyController.dispose();
    _jobEducationController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final firestoreService = ref.read(firestoreServiceProvider);
        final currentUser = ref.read(currentUserProvider);
        final currentProfile = ref.read(userProfileProvider).value;

        if (currentUser == null || currentProfile == null) return;

        final updatedProfile = UserModel(
          id: currentProfile.id,
          uid: currentProfile.uid,
          name: currentProfile.name,
          age: currentProfile.age,
          bio: _bioController.text.trim(),
          photos: currentProfile.photos,
          location: currentProfile.location,
          distance: currentProfile.distance,
          interests: _selectedInterests,
          gender: currentProfile.gender,
          sexualOrientation: currentProfile.sexualOrientation,
          job: UserJob(
            title: _jobTitleController.text.trim(),
            company: _jobCompanyController.text.trim(),
            education: _jobEducationController.text.trim(),
          ),
          lifestyle: UserLifestyle(
            drink: _drink,
            smoke: _smoke,
            workout: _workout,
            zodiac: _zodiac,
            height: _heightController.text.trim(),
          ),
          searchIntent: _searchIntent,
          active: currentProfile.active,
          createdAt: currentProfile.createdAt,
          updatedAt: DateTime.now(),
        );

        await firestoreService.updateUserProfile(updatedProfile);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil actualizado correctamente')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar perfil: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _toggleInterest(String interest) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bio
                CustomInput(
                  label: 'Sobre mí',
                  hint: 'Escribe algo sobre ti...',
                  icon: LucideIcons.alignLeft,
                  controller: _bioController,
                  maxLines: 4,
                ),
                const SizedBox(height: 24),

                // Interests
                const Text(
                  'Intereses',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableInterests.map((interest) {
                    final isSelected = _selectedInterests.contains(interest);
                    return FilterChip(
                      label: Text(interest),
                      selected: isSelected,
                      onSelected: (_) => _toggleInterest(interest),
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Job & Education
                const Text(
                  'Trabajo y Educación',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                CustomInput(
                  label: 'Puesto',
                  hint: 'Ej: Diseñador UX',
                  icon: LucideIcons.briefcase,
                  controller: _jobTitleController,
                ),
                const SizedBox(height: 16),
                CustomInput(
                  label: 'Empresa',
                  hint: 'Ej: Google',
                  icon: LucideIcons.building,
                  controller: _jobCompanyController,
                ),
                const SizedBox(height: 16),
                CustomInput(
                  label: 'Educación',
                  hint: 'Ej: Universidad de Buenos Aires',
                  icon: LucideIcons.graduationCap,
                  controller: _jobEducationController,
                ),
                const SizedBox(height: 24),

                // Lifestyle
                const Text(
                  'Estilo de Vida',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'Bebida',
                  value: _drink,
                  items: [
                    'Frecuentemente',
                    'Socialmente',
                    'Nunca',
                    'Prefiero no decir',
                  ],
                  onChanged: (val) => setState(() => _drink = val!),
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'Tabaco',
                  value: _smoke,
                  items: [
                    'Fumador',
                    'No fumador',
                    'Ocasionalmente',
                    'Prefiero no decir',
                  ],
                  onChanged: (val) => setState(() => _smoke = val!),
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'Ejercicio',
                  value: _workout,
                  items: ['Diario', 'A veces', 'Nunca', 'Prefiero no decir'],
                  onChanged: (val) => setState(() => _workout = val!),
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'Signo Zodiacal',
                  value: _zodiac,
                  items: [
                    'Aries',
                    'Tauro',
                    'Géminis',
                    'Cáncer',
                    'Leo',
                    'Virgo',
                    'Libra',
                    'Escorpio',
                    'Sagitario',
                    'Capricornio',
                    'Acuario',
                    'Piscis',
                  ],
                  onChanged: (val) => setState(() => _zodiac = val!),
                ),
                const SizedBox(height: 16),
                CustomInput(
                  label: 'Altura (cm)',
                  hint: 'Ej: 175',
                  icon: LucideIcons.ruler,
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),

                // Search Intent
                _buildDropdown(
                  label: 'Busco',
                  value: _searchIntent,
                  items: [
                    'Relación seria',
                    'Algo casual',
                    'Amistad',
                    'No lo sé aún',
                  ],
                  onChanged: (val) => setState(() => _searchIntent = val!),
                ),

                const SizedBox(height: 40),

                // Save Button
                GradientButton(
                  text: 'Guardar Cambios',
                  onPressed: _handleSave,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    // Ensure value is in items, if not, fallback to first item or add it
    if (!items.contains(value)) {
      if (items.isNotEmpty) {
        // value = items.first; // Don't mutate state during build
        // Instead, we can just display it if we add it to the list temporarily for display
        // or just accept that it might be inconsistent.
        // Better approach: Add 'Prefiero no decir' or similar if missing.
        if (!items.contains('Prefiero no decir')) {
          items = [...items, 'Prefiero no decir'];
        }
        if (!items.contains(value)) {
          value = items.first;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown),
              items: items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
