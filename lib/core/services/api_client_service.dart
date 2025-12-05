import 'package:dio/dio.dart';
import '../constants/env_config.dart';

class ApiClientService {
  final Dio _dio;

  ApiClientService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: EnvConfig.apiUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ),
      );

  /// Registrar token FCM en el servidor backend
  Future<void> registerFcmToken(String userId, String token) async {
    try {
      if (token.isEmpty) return;

      print('🌐 Registrando token FCM en servidor: ${EnvConfig.apiUrl}');

      // Asumiendo un endpoint estándar, esto puede cambiar según la implementación del backend
      await _dio.post(
        '/api/notifications/register-token',
        data: {
          'userId': userId,
          'token': token,
          'platform': 'flutter_app', // Identificador opcional
        },
      );

      print('✅ Token FCM registrado exitosamente en el backend');
    } catch (e) {
      // No bloqueamos la app si falla el registro en el backend
      print('⚠️ Error registrando token en backend: $e');
      if (e is DioException) {
        print('⚠️ Respuesta del servidor: ${e.response?.data}');
      }
    }
  }

  /// Eliminar token FCM del servidor backend
  Future<void> unregisterFcmToken(String userId, String token) async {
    try {
      if (token.isEmpty) return;

      print('🌐 Eliminando token FCM del servidor');

      await _dio.post(
        '/api/notifications/unregister-token',
        data: {'userId': userId, 'token': token},
      );

      print('✅ Token FCM eliminado exitosamente del backend');
    } catch (e) {
      print('⚠️ Error eliminando token en backend: $e');
    }
  }
}
