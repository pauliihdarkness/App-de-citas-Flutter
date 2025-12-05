import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get apiUrl {
    // En desarrollo, usar localhost si API_URL no está definida
    final envApiUrl = dotenv.env['API_URL'];
    if (envApiUrl == null || envApiUrl.isEmpty) {
      return 'http://localhost:3000';
    }
    return envApiUrl;
  }
}
