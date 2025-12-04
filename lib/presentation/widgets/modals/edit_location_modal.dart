import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme.dart';
import '../../widgets/gradient_button.dart';
import '../../providers/auth_provider.dart';
import '../../../core/services/location_service.dart';
import '../../../data/models/user_model.dart';

class EditLocationModal extends ConsumerStatefulWidget {
  const EditLocationModal({super.key});

  @override
  ConsumerState<EditLocationModal> createState() => _EditLocationModalState();
}

class _EditLocationModalState extends ConsumerState<EditLocationModal> {
  final _formKey = GlobalKey<FormState>();

  // Usamos un solo controlador para la búsqueda
  late TextEditingController _searchController;

  // Guardamos la ubicación seleccionada
  LocationData? _selectedLocation;

  bool _isLoading = false;
  bool _isDetectingLocation = false;

  @override
  void initState() {
    super.initState();
    final userProfile = ref.read(userProfileProvider).value;

    // Inicializar con la ubicación actual si existe
    if (userProfile?.location != null &&
        userProfile!.location.city.isNotEmpty) {
      _selectedLocation = LocationData(
        city: userProfile.location.city,
        state: userProfile.location.state,
        country: userProfile.location.country,
      );
      _searchController = TextEditingController(
        text: '${userProfile.location.city}, ${userProfile.location.state}',
      );
    } else {
      _searchController = TextEditingController();
    }

    // Cargar ubicaciones locales en segundo plano
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LocationService.instance.loadLocalLocations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() => _isDetectingLocation = true);

    try {
      final locationData = await LocationService.instance.getCurrentLocation();

      if (locationData != null) {
        setState(() {
          _selectedLocation = locationData;

          // Formatear texto para el input
          String displayText = locationData.city;
          if (locationData.state.isNotEmpty) {
            displayText += ', ${locationData.state}';
          }
          _searchController.text = displayText;
        });

        if (locationData.country.isEmpty && locationData.city.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Ubicación detectada. Por favor completa los detalles manualmente.',
                ),
                duration: Duration(seconds: 4),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo detectar la ubicación automáticamente'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isDetectingLocation = false);
      }
    }
  }

  Future<void> _handleSave() async {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una ubicación')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final currentProfile = ref.read(userProfileProvider).value;

      if (currentProfile == null) return;

      final updatedProfile = UserModel(
        id: currentProfile.id,
        uid: currentProfile.uid,
        name: currentProfile.name,
        age: currentProfile.age,
        bio: currentProfile.bio,
        photos: currentProfile.photos,
        location: UserLocation(
          country: _selectedLocation!.country,
          state: _selectedLocation!.state,
          city: _selectedLocation!.city,
        ),
        distance: currentProfile.distance,
        interests: currentProfile.interests,
        gender: currentProfile.gender,
        sexualOrientation: currentProfile.sexualOrientation,
        job: currentProfile.job,
        lifestyle: currentProfile.lifestyle,
        searchIntent: currentProfile.searchIntent,
        active: currentProfile.active,
        createdAt: currentProfile.createdAt,
        updatedAt: DateTime.now(),
      );

      await firestoreService.updateUserProfile(updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ubicación actualizada')));
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
                  'Ubicación',
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

            // Auto-detect button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isDetectingLocation ? null : _detectLocation,
                icon: _isDetectingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Icon(LucideIcons.locateFixed),
                label: Text(
                  _isDetectingLocation
                      ? 'Detectando...'
                      : 'Detectar mi ubicación',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Buscar Ciudad',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // Autocomplete Field
            LayoutBuilder(
              builder: (context, constraints) {
                return Autocomplete<LocationData>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<LocationData>.empty();
                    }
                    return LocationService.instance.searchLocalLocations(
                      textEditingValue.text,
                    );
                  },
                  displayStringForOption: (LocationData option) =>
                      '${option.city}, ${option.state}',
                  onSelected: (LocationData selection) {
                    setState(() {
                      _selectedLocation = selection;
                      _searchController.text =
                          '${selection.city}, ${selection.state}';
                    });
                  },
                  fieldViewBuilder:
                      (
                        BuildContext context,
                        TextEditingController fieldTextEditingController,
                        FocusNode fieldFocusNode,
                        VoidCallback onFieldSubmitted,
                      ) {
                        // Sincronizar controladores si es necesario
                        if (fieldTextEditingController.text !=
                            _searchController.text) {
                          fieldTextEditingController.text =
                              _searchController.text;
                        }

                        // Actualizar nuestro controlador cuando el usuario escribe
                        fieldTextEditingController.addListener(() {
                          _searchController.text =
                              fieldTextEditingController.text;
                        });

                        return TextFormField(
                          controller: fieldTextEditingController,
                          focusNode: fieldFocusNode,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Ej: Buenos Aires, Córdoba...',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            prefixIcon: const Icon(
                              LucideIcons.search,
                              color: AppColors.textSecondary,
                            ),
                            filled: true,
                            fillColor: AppColors.inputFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1,
                              ),
                            ),
                          ),
                        );
                      },
                  optionsViewBuilder:
                      (
                        BuildContext context,
                        AutocompleteOnSelected<LocationData> onSelected,
                        Iterable<LocationData> options,
                      ) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: constraints.maxWidth,
                              constraints: const BoxConstraints(maxHeight: 200),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.textSecondary.withOpacity(
                                    0.1,
                                  ),
                                ),
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final LocationData option = options.elementAt(
                                    index,
                                  );
                                  return ListTile(
                                    title: Text(
                                      option.city,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      option.state,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    onTap: () => onSelected(option),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                );
              },
            ),

            if (_selectedLocation != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ubicación Seleccionada:',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildLocationDetail('País', _selectedLocation!.country),
                    _buildLocationDetail('Provincia', _selectedLocation!.state),
                    _buildLocationDetail('Ciudad', _selectedLocation!.city),
                  ],
                ),
              ),
            ],

            const Spacer(),
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

  Widget _buildLocationDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
