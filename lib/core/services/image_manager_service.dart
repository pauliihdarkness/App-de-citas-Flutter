import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'cloudinary_service.dart';

/// Servicio para gestionar el flujo completo de imágenes:
/// - Selección (cámara/galería)
/// - Crop interactivo
/// - Compresión
/// - Subida a Cloudinary
class ImageManagerService {
  final CloudinaryService _cloudinaryService;
  final ImagePicker _imagePicker = ImagePicker();
  BuildContext? _context;

  ImageManagerService(this._cloudinaryService);

  void setContext(BuildContext context) {
    _context = context;
  }

  /// Selecciona una imagen desde la cámara o galería
  Future<XFile?> pickImage(ImageSource source) async {
    try {
      // Solicitar permisos según la fuente
      final hasPermission = await _requestPermission(source);
      if (!hasPermission) {
        throw Exception(
          'Permission denied for ${source == ImageSource.camera ? 'camera' : 'gallery'}',
        );
      }

      // Seleccionar imagen
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        print('ℹ️ Image selection cancelled');
        return null;
      }

      return pickedFile;
    } catch (e) {
      print('❌ Error picking image: $e');
      rethrow;
    }
  }

  /// Realiza crop interactivo de la imagen con ratio 4:5 (vertical)
  Future<XFile?> cropImage(XFile imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 5),
        compressQuality: 85,
        maxWidth: 1080,
        maxHeight: 1350,
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recortar imagen',
            toolbarColor: const Color(0xFFE94057),
            toolbarWidgetColor: Colors.white,
            backgroundColor: const Color(0xFF1A1A1A),
            activeControlsWidgetColor: const Color(0xFFE94057),
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
            hideBottomControls: false,
            statusBarColor: const Color(0xFF1A1A1A),
          ),
          IOSUiSettings(
            title: 'Recortar imagen',
            doneButtonTitle: 'Guardar',
            cancelButtonTitle: 'Cancelar',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
            hidesNavigationBar: false,
          ),
          if (kIsWeb && _context != null)
            WebUiSettings(
              context: _context!,
              presentStyle: WebPresentStyle.page,
              translations: const WebTranslations(
                title: 'Recortar imagen',
                cropButton: 'Guardar',
                cancelButton: 'Cancelar',
                rotateLeftTooltip: 'Girar izq.',
                rotateRightTooltip: 'Girar der.',
              ),
            ),
        ],
      );

      if (croppedFile == null) {
        print('ℹ️ Image cropping cancelled');
        return null;
      }

      return XFile(croppedFile.path);
    } catch (e) {
      print('❌ Error cropping image: $e');
      rethrow;
    }
  }

  /// Comprime la imagen si excede el tamaño máximo permitido
  Future<XFile> compressImage(XFile imageFile, {int maxSizeKB = 1024}) async {
    try {
      final fileSize = await imageFile.length();
      final fileSizeKB = fileSize / 1024;

      print('📊 Original file size: ${fileSizeKB.toStringAsFixed(2)} KB');

      if (fileSizeKB <= maxSizeKB) {
        print('✅ File size is within limit, no compression needed');
        return imageFile;
      }

      int quality = 85;
      if (fileSizeKB > maxSizeKB * 2) {
        quality = 70;
      } else if (fileSizeKB > maxSizeKB * 1.5) {
        quality = 75;
      } else {
        quality = 80;
      }

      if (kIsWeb) {
        // En Web usamos bytes directamente
        final bytes = await imageFile.readAsBytes();
        final compressedBytes = await FlutterImageCompress.compressWithList(
          bytes,
          minWidth: 1080,
          minHeight: 1350,
          quality: quality,
          format: CompressFormat.jpeg,
        );

        // Crear XFile desde bytes
        return XFile.fromData(
          compressedBytes,
          name: 'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
          mimeType: 'image/jpeg',
        );
      } else {
        // En móvil usamos archivos temporales
        final tempDir = await getTemporaryDirectory();
        final targetPath =
            '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          imageFile.path,
          targetPath,
          quality: quality,
          minWidth: 1080,
          minHeight: 1350,
          format: CompressFormat.jpeg,
        );

        if (compressedFile == null) {
          throw Exception('Image compression failed');
        }

        return compressedFile; // compressedFile ya es XFile
      }
    } catch (e) {
      print('❌ Error compressing image: $e');
      return imageFile;
    }
  }

  /// Flujo completo: seleccionar → crop → comprimir → subir
  Future<String?> uploadUserPhoto(
    ImageSource source,
    String userId, {
    Function(double)? onProgress,
  }) async {
    try {
      // 1. Seleccionar imagen (20%)
      onProgress?.call(0.2);
      final pickedFile = await pickImage(source);
      if (pickedFile == null) return null;

      // 2. Crop imagen (40%)
      onProgress?.call(0.4);
      final croppedFile = await cropImage(pickedFile);
      if (croppedFile == null) return null;

      // 3. Comprimir imagen (60%)
      onProgress?.call(0.6);
      final compressedFile = await compressImage(croppedFile);

      // 4. Subir a Cloudinary (80%)
      onProgress?.call(0.8);
      final imageUrl = await _cloudinaryService.uploadImage(
        compressedFile,
        userId,
      );

      // 5. Completado (100%)
      onProgress?.call(1.0);

      // Limpiar archivos temporales (solo móvil)
      if (!kIsWeb) {
        await _cleanupTempFiles([pickedFile, croppedFile, compressedFile]);
      }

      return imageUrl;
    } catch (e) {
      print('❌ Error in upload flow: $e');
      onProgress?.call(0.0);
      rethrow;
    }
  }

  /// Solicita permisos necesarios según la fuente de imagen
  Future<bool> _requestPermission(ImageSource source) async {
    if (kIsWeb) return true;

    try {
      Permission permission;

      if (source == ImageSource.camera) {
        permission = Permission.camera;
        print('📸 Requesting camera permission...');
      } else {
        // Para galería en Android, intentamos con diferentes permisos según la versión
        // Primero intentamos con Permission.photos (Android 13+)
        // Si falla, usamos Permission.storage (Android 10-12)
        if (Platform.isAndroid) {
          // Intentar primero con photos
          final photosStatus = await Permission.photos.status;
          print('📊 Photos permission status: $photosStatus');

          if (photosStatus == PermissionStatus.denied ||
              photosStatus == PermissionStatus.granted ||
              photosStatus == PermissionStatus.limited) {
            // Permission.photos está disponible (Android 13+)
            permission = Permission.photos;
            print('🖼️ Using Permission.photos (Android 13+)');
          } else {
            // Permission.photos no está disponible, usar storage
            permission = Permission.storage;
            print('🖼️ Using Permission.storage (Android < 13)');
          }
        } else {
          // iOS siempre usa photos
          permission = Permission.photos;
          print('🖼️ Using Permission.photos (iOS)');
        }
      }

      // Verificar estado actual
      final currentStatus = await permission.status;
      print('📊 Current permission status: $currentStatus');

      if (currentStatus.isGranted || currentStatus.isLimited) {
        print('✅ Permission already granted');
        return true;
      }

      if (currentStatus.isPermanentlyDenied) {
        print('⚠️ Permission permanently denied, opening settings...');
        await _showPermissionDialog(
          'Permiso Requerido',
          'Para ${source == ImageSource.camera ? 'tomar fotos' : 'seleccionar fotos de la galería'}, '
              'necesitas habilitar el permiso en la configuración de la aplicación.',
          showSettings: true,
        );
        return false;
      }

      // Solicitar permiso
      print('🔔 Requesting permission...');
      final status = await permission.request();
      print('📊 Permission request result: $status');

      if (status.isGranted || status.isLimited) {
        print('✅ Permission granted');
        return true;
      } else if (status.isPermanentlyDenied) {
        print('⚠️ Permission permanently denied after request');
        await _showPermissionDialog(
          'Permiso Denegado',
          'Has denegado el permiso permanentemente. Para continuar, '
              'debes habilitarlo manualmente en la configuración.',
          showSettings: true,
        );
        return false;
      } else {
        print('❌ Permission denied');
        await _showPermissionDialog(
          'Permiso Denegado',
          'Necesitamos acceso a ${source == ImageSource.camera ? 'la cámara' : 'tus fotos'} '
              'para que puedas ${source == ImageSource.camera ? 'tomar' : 'seleccionar'} imágenes.',
          showSettings: false,
        );
        return false;
      }
    } catch (e) {
      print('❌ Error requesting permission: $e');
      return false;
    }
  }

  /// Muestra un diálogo informativo sobre permisos
  Future<void> _showPermissionDialog(
    String title,
    String message, {
    required bool showSettings,
  }) async {
    if (_context == null || !_context!.mounted) return;

    return showDialog(
      context: _context!,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFFB0B0B0)),
            ),
          ),
          if (showSettings)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text(
                'Abrir Configuración',
                style: TextStyle(color: Color(0xFFE94057)),
              ),
            ),
        ],
      ),
    );
  }

  /// Limpia archivos temporales después de la subida
  Future<void> _cleanupTempFiles(List<XFile> files) async {
    if (kIsWeb) return;

    for (final file in files) {
      try {
        final ioFile = File(file.path);
        if (await ioFile.exists()) {
          await ioFile.delete();
        }
      } catch (e) {
        print('⚠️ Error deleting temp file: $e');
      }
    }
  }

  /// Valida que la imagen cumpla con los requisitos
  Future<bool> validateImage(XFile imageFile) async {
    return await _cloudinaryService.validateImage(imageFile);
  }
}
