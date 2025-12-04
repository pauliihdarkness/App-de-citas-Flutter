import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme.dart';
import '../../widgets/gradient_button.dart';
import '../../providers/auth_provider.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/photo_upload_widget.dart';
import '../../providers/photos_provider.dart';
import '../../../core/services/interests_service.dart';
import '../../../data/models/interest_model.dart';

// Modals
import '../../widgets/modals/edit_bio_modal.dart';
import '../../widgets/modals/edit_work_education_modal.dart';
import '../../widgets/modals/edit_search_intent_modal.dart';
import '../../widgets/modals/edit_interests_modal.dart';
import '../../widgets/modals/edit_lifestyle_modal.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  // State variables
  String _bio = '';
  UserJob _job = UserJob(title: '', company: '', education: '');
  String _searchIntent = 'No lo sé aún';
  List<Interest> _selectedInterests = [];
  UserLifestyle _lifestyle = UserLifestyle(
    drink: 'Prefiero no decir',
    smoke: 'Prefiero no decir',
    workout: 'Prefiero no decir',
    zodiac: 'Aries',
    height: '',
  );

  bool _isLoading = false;
  bool _isInitialized = false;
  bool _interestsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadInterests();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadUserData();
      _isInitialized = true;
    }
  }

  Future<void> _loadInterests() async {
    try {
      await InterestsService.instance.loadInterests();
      if (mounted) {
        setState(() {
          _interestsLoaded = true;
        });
        _loadUserData();
      }
    } catch (e) {
      print('Error loading interests: $e');
    }
  }

  void _loadUserData() {
    final userProfile = ref.read(userProfileProvider).value;
    if (userProfile != null) {
      setState(() {
        _bio = userProfile.bio;
        _job = userProfile.job;
        _searchIntent = userProfile.searchIntent.isNotEmpty
            ? userProfile.searchIntent
            : 'No lo sé aún';
        _lifestyle = userProfile.lifestyle;

        if (_interestsLoaded) {
          _selectedInterests = InterestsService.instance
              .convertNamesToInterests(userProfile.interests);
        }
      });
    }
  }

  // --- Modal Openers ---

  void _openBioModal() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditBioModal(initialBio: _bio),
    );

    if (result != null) {
      setState(() => _bio = result);
    }
  }

  void _openWorkEducationModal() async {
    final result = await showModalBottomSheet<UserJob>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditWorkEducationModal(initialJob: _job),
    );

    if (result != null) {
      setState(() => _job = result);
    }
  }

  void _openSearchIntentModal() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => EditSearchIntentModal(initialIntent: _searchIntent),
    );

    if (result != null) {
      setState(() => _searchIntent = result);
    }
  }

  void _openInterestsModal() async {
    final result = await showModalBottomSheet<List<Interest>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          EditInterestsModal(selectedInterests: _selectedInterests),
    );

    if (result != null) {
      setState(() => _selectedInterests = result);
    }
  }

  void _openLifestyleModal() async {
    final result = await showModalBottomSheet<UserLifestyle>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditLifestyleModal(initialLifestyle: _lifestyle),
    );

    if (result != null) {
      setState(() => _lifestyle = result);
    }
  }

  // --- Save Handler ---

  Future<void> _handleSave() async {
    // Validar fotos mínimas
    final photosState = ref.read(photosProvider);
    if (!photosState.meetsMinimum) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debes subir al menos ${photosState.minPhotos} fotos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
        bio: _bio,
        photos: photosState.photos,
        location: currentProfile.location,
        distance: currentProfile.distance,
        interests: InterestsService.instance.convertInterestsToNames(
          _selectedInterests,
        ),
        gender: currentProfile.gender,
        sexualOrientation: currentProfile.sexualOrientation,
        job: _job,
        lifestyle: _lifestyle,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fotos
              const Text(
                'Mis Fotos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const PhotoUploadWidget(),
              const SizedBox(height: 32),

              // Bio
              _buildSectionTile(
                title: 'Sobre mí',
                value: _bio.isEmpty ? 'Escribe algo sobre ti...' : _bio,
                icon: LucideIcons.alignLeft,
                onTap: _openBioModal,
              ),
              const SizedBox(height: 16),

              // Trabajo y Educación
              _buildSectionTile(
                title: 'Trabajo y Educación',
                value: _getJobSummary(),
                icon: LucideIcons.briefcase,
                onTap: _openWorkEducationModal,
              ),
              const SizedBox(height: 16),

              // Qué busco
              _buildSectionTile(
                title: 'Qué busco',
                value: _searchIntent,
                icon: LucideIcons.search,
                onTap: _openSearchIntentModal,
              ),
              const SizedBox(height: 16),

              // Intereses
              _buildSectionTile(
                title: 'Intereses',
                value: _selectedInterests.isEmpty
                    ? 'Selecciona tus intereses'
                    : '${_selectedInterests.length} intereses seleccionados',
                icon: LucideIcons.heart,
                onTap: _openInterestsModal,
                child: _selectedInterests.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedInterests.map((interest) {
                            return Chip(
                              label: Text(
                                interest.displayName,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: AppColors.glassBg,
                              labelStyle: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),

              // Estilo de Vida
              _buildSectionTile(
                title: 'Estilo de Vida',
                value: _getLifestyleSummary(),
                icon: LucideIcons.coffee,
                onTap: _openLifestyleModal,
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
    );
  }

  String _getJobSummary() {
    final parts = <String>[];
    if (_job.title.isNotEmpty) parts.add(_job.title);
    if (_job.company.isNotEmpty) parts.add(_job.company);
    if (_job.education.isNotEmpty) parts.add(_job.education);
    return parts.isEmpty
        ? 'Añade detalles de trabajo/estudio'
        : parts.join(', ');
  }

  String _getLifestyleSummary() {
    final parts = <String>[];
    if (_lifestyle.drink != 'Prefiero no decir')
      parts.add('Bebida: ${_lifestyle.drink}');
    if (_lifestyle.smoke != 'Prefiero no decir')
      parts.add('Tabaco: ${_lifestyle.smoke}');
    if (_lifestyle.workout != 'Prefiero no decir')
      parts.add('Ejercicio: ${_lifestyle.workout}');
    if (_lifestyle.zodiac.isNotEmpty) parts.add('Signo: ${_lifestyle.zodiac}');
    if (_lifestyle.height.isNotEmpty)
      parts.add('Altura: ${_lifestyle.height}cm');

    return parts.isEmpty
        ? 'Añade detalles de estilo de vida'
        : parts.join('\n');
  }

  Widget _buildSectionTile({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    Widget? child,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.glassBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  LucideIcons.chevronRight,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (child != null) ...[
              const SizedBox(height: 8),
              Padding(padding: const EdgeInsets.only(left: 32), child: child),
            ],
          ],
        ),
      ),
    );
  }
}
