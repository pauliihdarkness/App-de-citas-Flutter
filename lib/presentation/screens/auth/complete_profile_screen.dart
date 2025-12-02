import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/gradient_button.dart';
import '../../providers/auth_provider.dart';
import '../../../data/models/user_model.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedGender = 'Hombre';
  String _selectedOrientation = 'Heterosexual';
  bool _isLoading = false;

  final List<String> _genders = [
    'Mujer',
    'Mujer Trans',
    'Hombre Trans',
    'Adrogine',
    'No binario',
    'No binario Trans',
    'Genderfluid',
    'Genderqueer',
    'Bigenero',
    'Hombre',
    'Otro',
    'Prefiero no decir',
  ];

  final List<String> _orientations = [
    'Heterosexual',
    'Gay',
    'Lesbiana',
    'Pansexual',
    'Bisexual',
    'Asexual',
    'Otro',
    'Prefiero no decir',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime eighteenYearsAgo = DateTime(
      now.year - 18,
      now.month,
      now.day,
    );

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: eighteenYearsAgo,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null && picked != _selectedDate) {
      // Validar que sea mayor de 18
      if (picked.isAfter(eighteenYearsAgo)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Debes tener al menos 18 años para registrarte.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _selectedDate = picked;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona tu fecha de nacimiento'),
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final authService = ref.read(authServiceProvider);
        final firestoreService = ref.read(firestoreServiceProvider);
        final currentUser = authService.currentUser;

        if (currentUser == null) throw Exception('No user logged in');

        // 1. Obtener perfil actual
        final currentProfile = await firestoreService.getUser(currentUser.uid);

        // 2. Calcular edad
        final age = _calculateAge(_selectedDate!);

        UserModel updatedProfile;

        if (currentProfile != null) {
          // Actualizar perfil existente
          updatedProfile = UserModel(
            id: currentProfile.id,
            uid: currentProfile.uid,
            name: _nameController.text.trim(),
            age: age,
            bio: currentProfile.bio,
            photos: currentProfile.photos,
            location: UserLocation(
              country: _countryController.text.trim(),
              state: _stateController.text.trim(),
              city: _cityController.text.trim(),
            ),
            distance: currentProfile.distance,
            interests: currentProfile.interests,
            gender: _selectedGender,
            sexualOrientation: _selectedOrientation,
            job: currentProfile.job,
            lifestyle: currentProfile.lifestyle,
            searchIntent: currentProfile.searchIntent,
            active: true,
            createdAt: currentProfile.createdAt,
            updatedAt: DateTime.now(),
          );
          await firestoreService.updateUserProfile(updatedProfile);
        } else {
          // Crear nuevo perfil si no existe (Robustez)
          updatedProfile = UserModel(
            id: currentUser.uid,
            uid: currentUser.uid,
            name: _nameController.text.trim(),
            age: age,
            bio: '¡Hola! Soy nuevo aquí.',
            photos: [],
            location: UserLocation(
              country: _countryController.text.trim(),
              state: _stateController.text.trim(),
              city: _cityController.text.trim(),
            ),
            gender: _selectedGender,
            sexualOrientation: _selectedOrientation,
            job: UserJob(title: '', company: '', education: ''),
            lifestyle: UserLifestyle(
              drink: '',
              smoke: '',
              workout: '',
              zodiac: '',
              height: '',
            ),
            searchIntent: 'No lo sé aún',
            active: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await firestoreService.createUser(updatedProfile);
        }

        // 5. Crear documento privado con datos sensibles (una sola vez)
        print('💾 Creating private data...');
        try {
          final authMethod =
              currentUser.providerData.any((p) => p.providerId == 'google.com')
              ? 'google'
              : 'email';

          await firestoreService.setPrivateData(currentUser.uid, {
            'email': currentUser.email,
            'authMethod': authMethod,
            'birthDate': DateFormat('yyyy-MM-dd').format(_selectedDate!),
          });
          print('✅ Private data created');
        } catch (e) {
          print('⚠️ Error creating private data: $e');
          // Re-lanzamos el error porque sin datos privados el perfil está incompleto
          rethrow;
        }

        if (mounted) {
          print('🚀 Navigating to home...');
          context.go('/home');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar perfil: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completa tu Perfil'),
        centerTitle: true,
        automaticallyImplyLeading: false, // No permitir volver atrás
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¡Casi listo!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Necesitamos algunos datos para encontrarte las mejores parejas.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),

                // Nombre
                CustomInput(
                  label: 'Nombre',
                  hint: 'Tu nombre',
                  icon: LucideIcons.user,
                  controller: _nameController,
                  validator: (value) =>
                      value!.isEmpty ? 'Ingresa tu nombre' : null,
                ),
                const SizedBox(height: 24),

                // Fecha de Nacimiento
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: CustomInput(
                      label: 'Fecha de Nacimiento',
                      hint: 'DD/MM/AAAA',
                      icon: LucideIcons.calendar,
                      controller: _birthDateController,
                      validator: (value) => value!.isEmpty
                          ? 'Selecciona tu fecha de nacimiento'
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Género
                _buildDropdown(
                  label: 'Género',
                  value: _selectedGender,
                  items: _genders,
                  onChanged: (value) =>
                      setState(() => _selectedGender = value!),
                ),
                const SizedBox(height: 24),

                // Orientación Sexual
                _buildDropdown(
                  label: 'Orientación Sexual',
                  value: _selectedOrientation,
                  items: _orientations,
                  onChanged: (value) =>
                      setState(() => _selectedOrientation = value!),
                ),
                const SizedBox(height: 24),

                // Ubicación
                const Text(
                  'Ubicación',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                CustomInput(
                  label: 'País',
                  hint: 'Ej: Argentina',
                  icon: LucideIcons.mapPin,
                  controller: _countryController,
                  validator: (value) =>
                      value!.isEmpty ? 'Ingresa tu país' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomInput(
                        label: 'Provincia/Estado',
                        hint: 'Ej: Buenos Aires',
                        icon: LucideIcons.map,
                        controller: _stateController,
                        validator: (value) =>
                            value!.isEmpty ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomInput(
                        label: 'Ciudad',
                        hint: 'Ej: CABA',
                        icon: LucideIcons.building,
                        controller: _cityController,
                        validator: (value) =>
                            value!.isEmpty ? 'Requerido' : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Botón Guardar
                GradientButton(
                  text: 'Guardar y Continuar',
                  onPressed: _handleSave,
                  isLoading: _isLoading,
                ),
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
