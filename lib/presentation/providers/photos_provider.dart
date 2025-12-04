import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/cloudinary_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/image_manager_service.dart';
import 'auth_provider.dart';

// Estado de las fotos
class PhotosState {
  final List<String> photos;
  final bool isLoading;
  final double uploadProgress;
  final String? error;
  final int maxPhotos;
  final int minPhotos;

  const PhotosState({
    this.photos = const [],
    this.isLoading = false,
    this.uploadProgress = 0.0,
    this.error,
    this.maxPhotos = 9,
    this.minPhotos = 1,
  });

  PhotosState copyWith({
    List<String>? photos,
    bool? isLoading,
    double? uploadProgress,
    String? error,
  }) {
    return PhotosState(
      photos: photos ?? this.photos,
      isLoading: isLoading ?? this.isLoading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      error: error, // Si se pasa null, se limpia el error
      maxPhotos: this.maxPhotos,
      minPhotos: this.minPhotos,
    );
  }

  bool get canAddMore => photos.length < maxPhotos;
  bool get meetsMinimum => photos.length >= minPhotos;
}

// Provider del servicio de Cloudinary
final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  return CloudinaryService();
});

// Provider del servicio de gestión de imágenes
final imageManagerServiceProvider = Provider<ImageManagerService>((ref) {
  final cloudinaryService = ref.watch(cloudinaryServiceProvider);
  return ImageManagerService(cloudinaryService);
});

// Notifier para gestionar las fotos
class PhotosNotifier extends StateNotifier<PhotosState> {
  final ImageManagerService _imageManagerService;
  final FirestoreService _firestoreService;
  final String? _userId;

  PhotosNotifier(
    this._imageManagerService,
    this._firestoreService,
    this._userId,
  ) : super(const PhotosState()) {
    if (_userId != null) {
      _loadPhotos();
    }
  }

  void setContext(BuildContext context) {
    _imageManagerService.setContext(context);
  }

  Future<void> _loadPhotos() async {
    if (_userId == null) return;

    try {
      state = state.copyWith(isLoading: true);
      final user = await _firestoreService.getUser(_userId);
      if (user != null) {
        state = state.copyWith(photos: user.photos, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading photos: $e',
      );
    }
  }

  Future<void> addPhoto(ImageSource source) async {
    if (_userId == null) return;
    if (!state.canAddMore) {
      state = state.copyWith(
        error: 'Maximum limit of ${state.maxPhotos} photos reached',
      );
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null, uploadProgress: 0.1);

      final imageUrl = await _imageManagerService.uploadUserPhoto(
        source,
        _userId,
        onProgress: (progress) {
          state = state.copyWith(uploadProgress: progress);
        },
      );

      if (imageUrl != null) {
        // Actualizar Firestore
        await _firestoreService.addUserPhoto(_userId, imageUrl);

        // Actualizar estado local
        final newPhotos = [...state.photos, imageUrl];
        state = state.copyWith(
          photos: newPhotos,
          isLoading: false,
          uploadProgress: 0.0,
        );
      } else {
        // Cancelado por el usuario
        state = state.copyWith(isLoading: false, uploadProgress: 0.0);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        uploadProgress: 0.0,
        error: 'Error adding photo: $e',
      );
    }
  }

  Future<void> removePhoto(String photoUrl) async {
    if (_userId == null) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      await _firestoreService.removeUserPhoto(_userId, photoUrl);

      final newPhotos = state.photos.where((url) => url != photoUrl).toList();
      state = state.copyWith(photos: newPhotos, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error removing photo: $e',
      );
    }
  }

  Future<void> reorderPhotos(int oldIndex, int newIndex) async {
    if (_userId == null) return;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final newPhotos = [...state.photos];
    final item = newPhotos.removeAt(oldIndex);
    newPhotos.insert(newIndex, item);

    // Actualizar estado local inmediatamente (optimistic update)
    state = state.copyWith(photos: newPhotos);

    try {
      // Actualizar Firestore
      await _firestoreService.updateUserPhotos(_userId, newPhotos);
    } catch (e) {
      // Revertir si falla
      _loadPhotos();
      state = state.copyWith(error: 'Error reordering photos: $e');
    }
  }
}

// Provider global de fotos
final photosProvider = StateNotifierProvider<PhotosNotifier, PhotosState>((
  ref,
) {
  final user = ref.watch(currentUserProvider);
  final imageManagerService = ref.watch(imageManagerServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);

  return PhotosNotifier(imageManagerService, firestoreService, user?.uid);
});
