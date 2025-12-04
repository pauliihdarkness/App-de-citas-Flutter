import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  /// Solicita permiso para acceder a la cámara
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        return true;
      }
    }

    if (status.isPermanentlyDenied ||
        await Permission.camera.isPermanentlyDenied) {
      if (context.mounted) {
        _showPermissionDeniedDialog(
          context,
          'Permiso de Cámara',
          'Para tomar fotos, necesitas habilitar el permiso de cámara en la configuración de la aplicación.',
        );
      }
      return false;
    }

    return false;
  }

  /// Solicita permiso para acceder a la galería/almacenamiento
  static Future<bool> requestStoragePermission(BuildContext context) async {
    // Para Android 13+ (API 33+), usamos READ_MEDIA_IMAGES
    // Para versiones anteriores, usamos READ_EXTERNAL_STORAGE
    PermissionStatus status;

    if (await _isAndroid13OrHigher()) {
      status = await Permission.photos.status;

      if (status.isGranted) {
        return true;
      }

      if (status.isDenied) {
        final result = await Permission.photos.request();
        if (result.isGranted) {
          return true;
        }
      }

      if (status.isPermanentlyDenied ||
          await Permission.photos.isPermanentlyDenied) {
        if (context.mounted) {
          _showPermissionDeniedDialog(
            context,
            'Permiso de Fotos',
            'Para seleccionar fotos, necesitas habilitar el permiso de fotos en la configuración de la aplicación.',
          );
        }
        return false;
      }
    } else {
      status = await Permission.storage.status;

      if (status.isGranted) {
        return true;
      }

      if (status.isDenied) {
        final result = await Permission.storage.request();
        if (result.isGranted) {
          return true;
        }
      }

      if (status.isPermanentlyDenied ||
          await Permission.storage.isPermanentlyDenied) {
        if (context.mounted) {
          _showPermissionDeniedDialog(
            context,
            'Permiso de Almacenamiento',
            'Para seleccionar fotos, necesitas habilitar el permiso de almacenamiento en la configuración de la aplicación.',
          );
        }
        return false;
      }
    }

    return false;
  }

  /// Verifica si el dispositivo es Android 13 o superior
  static Future<bool> _isAndroid13OrHigher() async {
    // En Flutter, podemos usar device_info_plus para obtener la versión de Android
    // Por ahora, intentamos primero con Permission.photos
    return await Permission.photos.status != PermissionStatus.denied;
  }

  /// Muestra un diálogo cuando el permiso ha sido denegado permanentemente
  static void _showPermissionDeniedDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Abrir Configuración'),
          ),
        ],
      ),
    );
  }

  /// Solicita todos los permisos necesarios para la aplicación
  static Future<Map<String, bool>> requestAllPermissions(
    BuildContext context,
  ) async {
    return {
      'camera': await requestCameraPermission(context),
      'storage': await requestStoragePermission(context),
    };
  }
}
