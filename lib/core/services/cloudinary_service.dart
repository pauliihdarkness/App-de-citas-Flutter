import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

/// Servicio para gestionar la subida y eliminación de imágenes en Cloudinary
class CloudinaryService {
  // SDK de Cloudinary (opcional, solo si hay credenciales)
  Cloudinary? _cloudinary;

  late final String _cloudName;
  late final String _uploadPreset;
  late final String _baseUrl;
  final Dio _dio = Dio();

  CloudinaryService() {
    _cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    _uploadPreset = dotenv.env['CLOUDINARY_PRESET_NAME'] ?? '';
    _baseUrl =
        dotenv.env['CLOUDINARY_URL_STORAGE'] ??
        'https://api.cloudinary.com/v1_1/';

    if (_cloudName.isEmpty || _uploadPreset.isEmpty) {
      print(
        '⚠️ Cloudinary configuration missing: CLOUD_NAME or PRESET_NAME not found.',
      );
      // No lanzamos excepción para no crashear la app, pero las subidas fallarán.
    }

    // Intentar inicializar SDK solo si hay credenciales completas
    final apiKey = dotenv.env['CLOUDINARY_API_KEY'];
    final apiSecret =
        dotenv.env['CLOUDINARY_API_SECRET'] ??
        dotenv.env['CLOUDINARY_API_SECRET_KEY'];

    if (apiKey != null &&
        apiKey.isNotEmpty &&
        apiSecret != null &&
        apiSecret.isNotEmpty) {
      try {
        _cloudinary = Cloudinary.full(
          apiKey: apiKey,
          apiSecret: apiSecret,
          cloudName: _cloudName,
        );
        print('✅ Cloudinary SDK initialized successfully');
      } catch (e) {
        print('⚠️ Could not initialize Cloudinary SDK: $e');
      }
    } else {
      print(
        'ℹ️ Cloudinary running in unsigned mode (Upload only). Add API_KEY and API_SECRET to .env to enable deletion.',
      );
    }
  }

  /// Sube una imagen a Cloudinary y retorna la URL optimizada
  ///
  /// [imageFile] - Archivo de imagen a subir
  /// [userId] - ID del usuario (para organizar en carpetas)
  /// [folder] - Carpeta opcional dentro de app-de-citas/users/{userId}/
  ///
  /// Retorna la URL de la imagen subida con optimizaciones aplicadas
  /// Sube una imagen a Cloudinary y retorna la URL optimizada
  ///
  /// [imageFile] - Archivo de imagen a subir (XFile para compatibilidad Web)
  /// [userId] - ID del usuario (para organizar en carpetas)
  /// [folder] - Carpeta opcional dentro de app-de-citas/users/{userId}/
  ///
  /// Retorna la URL de la imagen subida con optimizaciones aplicadas
  Future<String> uploadImage(
    XFile imageFile,
    String userId, {
    String? folder,
  }) async {
    try {
      // Validar imagen antes de subir
      final isValid = await validateImage(imageFile);
      if (!isValid) {
        throw Exception(
          'Image validation failed: file too large or invalid format',
        );
      }

      // Construir la carpeta de destino
      final destinationFolder = folder != null
          ? 'app-de-citas/users/$userId/$folder'
          : 'app-de-citas/users/$userId';

      // URL de upload
      final uploadUrl = '$_baseUrl$_cloudName/image/upload';

      // Preparar FormData
      FormData formData;

      // Asegurar que el filename tenga extensión
      String filename = imageFile.name;
      if (!filename.contains('.')) {
        final mimeType = imageFile.mimeType;
        if (mimeType != null) {
          if (mimeType.contains('jpeg') || mimeType.contains('jpg')) {
            filename = '$filename.jpg';
          } else if (mimeType.contains('png')) {
            filename = '$filename.png';
          } else if (mimeType.contains('webp')) {
            filename = '$filename.webp';
          } else {
            // Default fallback
            filename = '$filename.jpg';
          }
        } else {
          filename = '$filename.jpg';
        }
      }

      if (kIsWeb) {
        // En Web usamos bytes
        final bytes = await imageFile.readAsBytes();
        formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(bytes, filename: filename),
          'upload_preset': _uploadPreset,
          'folder': destinationFolder,
        });
      } else {
        // En Móvil usamos path
        formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(
            imageFile.path,
            filename: filename,
          ),
          'upload_preset': _uploadPreset,
          'folder': destinationFolder,
        });
      }

      // Realizar upload
      final response = await _dio.post(
        uploadUrl,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final secureUrl = data['secure_url'] as String;
        final publicId = data['public_id'] as String;

        print('✅ Image uploaded successfully: $publicId');
        return secureUrl;
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioError uploading image: ${e.message}');
      if (e.response != null) {
        print('❌ Cloudinary Error Response: ${e.response?.data}');
        print('❌ Status Code: ${e.response?.statusCode}');
      }
      rethrow;
    } catch (e) {
      print('❌ Error uploading image to Cloudinary: $e');
      rethrow;
    }
  }

  /// Elimina una imagen de Cloudinary usando su public_id
  ///
  /// [publicId] - ID público de la imagen en Cloudinary
  /// Ejemplo: 'app-de-citas/users/user123/photo_1'
  Future<void> deleteImage(String publicId) async {
    if (_cloudinary == null) {
      print('⚠️ Cannot delete image: API_KEY and API_SECRET not configured.');
      return;
    }

    try {
      final response = await _cloudinary!.deleteResource(
        url: publicId,
        resourceType: CloudinaryResourceType.image,
        invalidate: true,
      );

      if (response.isSuccessful) {
        print('✅ Image deleted successfully: $publicId');
      } else {
        print('⚠️ Failed to delete image: ${response.error}');
        throw Exception('Failed to delete image: ${response.error}');
      }
    } catch (e) {
      print('❌ Error deleting image from Cloudinary: $e');
      rethrow;
    }
  }

  /// Extrae el public_id de una URL de Cloudinary
  ///
  /// [url] - URL completa de la imagen
  /// Retorna el public_id o null si no se puede extraer
  String? getPublicIdFromUrl(String url) {
    try {
      // Ejemplo de URL: https://res.cloudinary.com/dgswnms90/image/upload/v1234567890/app-de-citas/users/user123/photo_1.jpg
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      // Buscar el índice de 'upload'
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex == -1 || uploadIndex >= pathSegments.length - 2) {
        return null;
      }

      // El public_id está después de 'upload' y la versión
      // Ejemplo: ['upload', 'v1234567890', 'app-de-citas', 'users', 'user123', 'photo_1.jpg']
      final publicIdParts = pathSegments.sublist(uploadIndex + 2);
      final publicId = publicIdParts.join('/');

      // Remover la extensión del archivo
      return publicId.replaceAll(RegExp(r'\.[^.]+$'), '');
    } catch (e) {
      print('❌ Error extracting public_id from URL: $e');
      return null;
    }
  }

  /// Genera una URL optimizada con transformaciones personalizadas
  ///
  /// [publicId] - ID público de la imagen
  /// [width] - Ancho deseado (opcional)
  /// [height] - Alto deseado (opcional)
  /// [quality] - Calidad de la imagen (opcional, por defecto 'auto')
  ///
  /// Retorna URL con transformaciones aplicadas
  String getOptimizedUrl(
    String publicId, {
    int? width,
    int? height,
    String quality = 'auto',
  }) {
    final transformations = <String>[];

    // Calidad automática
    transformations.add('q_$quality');

    // Formato automático (WebP en navegadores compatibles)
    transformations.add('f_auto');

    // Dimensiones si se especifican
    if (width != null || height != null) {
      transformations.add('c_fill');
      if (width != null) transformations.add('w_$width');
      if (height != null) transformations.add('h_$height');
    }

    final transformationString = transformations.join(',');

    return 'https://res.cloudinary.com/$_cloudName/image/upload/$transformationString/$publicId';
  }

  /// Valida que la imagen cumpla con los requisitos antes de subir
  ///
  /// Requisitos:
  /// - Tamaño máximo: 10MB (antes de comprimir)
  /// - Formatos permitidos: JPG, PNG, WebP
  ///
  /// Retorna true si la imagen es válida, false en caso contrario
  Future<bool> validateImage(XFile imageFile) async {
    try {
      // Verificar tamaño del archivo (máx 10MB antes de comprimir)
      final fileSize = await imageFile.length();
      const maxSize = 10 * 1024 * 1024; // 10MB en bytes

      if (fileSize > maxSize) {
        print('❌ File too large: ${fileSize / 1024 / 1024}MB (max 10MB)');
        return false;
      }

      // Verificar extensión del archivo
      String extension = imageFile.name.split('.').last.toLowerCase();

      // Si no hay extensión (común en blobs), intentar deducir por mimeType
      if (extension == imageFile.name.toLowerCase() || extension.isEmpty) {
        final mimeType = imageFile.mimeType;
        if (mimeType != null) {
          if (mimeType.contains('jpeg') || mimeType.contains('jpg'))
            extension = 'jpg';
          else if (mimeType.contains('png'))
            extension = 'png';
          else if (mimeType.contains('webp'))
            extension = 'webp';
        }
      }

      final allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

      if (!allowedExtensions.contains(extension)) {
        // Fallback final: si es web y no pudimos determinar extensión, asumimos válido si es pequeño
        // Esto es arriesgado pero necesario para algunos blobs
        if (kIsWeb && fileSize < maxSize) {
          print(
            '⚠️ Warning: Could not determine extension, but allowing upload due to Web context.',
          );
          return true;
        }

        print('❌ Invalid file format: $extension (allowed: jpg, png, webp)');
        return false;
      }

      return true;
    } catch (e) {
      print('❌ Error validating image: $e');
      return false;
    }
  }

  /// Obtiene el nombre del cloud configurado
  String get cloudName => _cloudName;

  /// Obtiene el nombre del preset configurado
  String get uploadPreset => _uploadPreset;
}
