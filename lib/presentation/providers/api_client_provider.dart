import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_client_service.dart';

/// Provider global para el servicio de cliente API
final apiClientProvider = Provider<ApiClientService>((ref) {
  return ApiClientService();
});
