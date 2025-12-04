import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import '../providers/photos_provider.dart';
import 'photo_item.dart';
import 'photo_picker_sheet.dart';

class PhotoUploadWidget extends ConsumerWidget {
  const PhotoUploadWidget({super.key});

  void _showPicker(BuildContext context, WidgetRef ref) {
    // Setear contexto para el cropper en web
    ref.read(photosProvider.notifier).setContext(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => PhotoPickerSheet(
        onImageSelected: (source) {
          ref.read(photosProvider.notifier).addPhoto(source);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(photosProvider);
    final photos = state.photos;
    final isLoading = state.isLoading;
    final progress = state.uploadProgress;

    // Calcular items totales (fotos + placeholders)
    // Siempre mostramos al menos un placeholder si no se ha alcanzado el límite
    final showPlaceholder = photos.length < state.maxPhotos;
    final totalItems = photos.length + (showPlaceholder ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grid de Fotos
        ReorderableGridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8, // 4:5 ratio
          ),
          itemCount: totalItems,
          onReorder: (oldIndex, newIndex) {
            // No permitir reordenar el placeholder
            if (oldIndex >= photos.length || newIndex >= photos.length) return;
            ref.read(photosProvider.notifier).reorderPhotos(oldIndex, newIndex);
          },
          itemBuilder: (context, index) {
            // Placeholder Item
            if (index >= photos.length) {
              return PhotoItem(
                key: const ValueKey('placeholder'),
                isPlaceholder: true,
                onAdd: isLoading ? null : () => _showPicker(context, ref),
              );
            }

            // Photo Item
            final photoUrl = photos[index];
            final isLastAdded = index == photos.length - 1;

            // Mostrar loading solo en la última foto si se está subiendo
            final showLoading = isLoading && isLastAdded && progress > 0;

            return PhotoItem(
              key: ValueKey(photoUrl),
              imageUrl: photoUrl,
              isLoading: showLoading,
              progress: showLoading ? progress : null,
              onRemove: isLoading
                  ? null
                  : () =>
                        ref.read(photosProvider.notifier).removePhoto(photoUrl),
            );
          },
        ),

        // Mensaje de error
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              state.error!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),

        // Contador
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${photos.length}/${state.maxPhotos} fotos',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              if (!state.meetsMinimum)
                Text(
                  'Mínimo ${state.minPhotos} requeridas',
                  style: const TextStyle(
                    color: Color(0xFFE94057),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
