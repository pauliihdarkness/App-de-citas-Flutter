import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:dio/dio.dart';

class LocationData {
  final String city;
  final String state;
  final String country;
  final double? latitude;
  final double? longitude;

  LocationData({
    required this.city,
    required this.state,
    required this.country,
    this.latitude,
    this.longitude,
  });

  @override
  String toString() => '$city, $state, $country';
}

class LocationService {
  static LocationService? _instance;
  static LocationService get instance {
    _instance ??= LocationService._();
    return _instance!;
  }

  LocationService._();

  /// Verifica si los servicios de ubicación están habilitados
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Solicita permisos de ubicación
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permisos denegados permanentemente
      return false;
    }

    return true;
  }

  /// Obtiene la ubicación actual del dispositivo
  Future<Position?> getCurrentPosition() async {
    try {
      // Verificar si el servicio de ubicación está habilitado
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Los servicios de ubicación están deshabilitados');
      }

      // Verificar permisos
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        throw Exception('Permisos de ubicación denegados');
      }

      // Obtener posición actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      print('❌ Error getting current position: $e');
      rethrow;
    }
  }

  /// Convierte coordenadas a dirección (Geocodificación inversa)
  Future<LocationData?> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    try {
      // Intentar primero con el geocodificador nativo
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          latitude,
          longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          return LocationData(
            city: place.locality ?? place.subAdministrativeArea ?? '',
            state: place.administrativeArea ?? '',
            country: place.country ?? '',
            latitude: latitude,
            longitude: longitude,
          );
        }
      } catch (e) {
        print('⚠️ Native geocoding failed, trying Nominatim: $e');
      }

      // Fallback: Usar Nominatim (OpenStreetMap)
      final dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': latitude,
          'lon': longitude,
          'zoom': 10, // Zoom level for city/state precision
          'addressdetails': 1,
        },
        options: Options(
          headers: {
            'User-Agent': 'AppCitas/1.0', // Requerido por Nominatim
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final address = data['address'];

        return LocationData(
          city: address['city'] ?? address['town'] ?? address['village'] ?? '',
          state: address['state'] ?? address['province'] ?? '',
          country: address['country'] ?? '',
          latitude: latitude,
          longitude: longitude,
        );
      }

      throw Exception('Failed to geocode with both providers');
    } catch (e) {
      print('❌ Error in reverse geocoding: $e');
      // Fallback final: Retornar solo coordenadas
      return LocationData(
        city: '',
        state: '',
        country: '',
        latitude: latitude,
        longitude: longitude,
      );
    }
  }

  /// Obtiene la ubicación actual y la convierte a dirección
  Future<LocationData?> getCurrentLocation() async {
    try {
      // Obtener posición
      Position? position = await getCurrentPosition();
      if (position == null) {
        return null;
      }

      print('📍 Position: ${position.latitude}, ${position.longitude}');

      // Convertir a dirección
      LocationData? location = await reverseGeocode(
        position.latitude,
        position.longitude,
      );

      if (location != null) {
        print(
          '✅ Location: ${location.city}, ${location.state}, ${location.country}',
        );
      }

      return location;
    } catch (e) {
      print('❌ Error getting current location: $e');
      rethrow;
    }
  }

  /// Busca ubicaciones por nombre (para autocomplete)
  Future<List<LocationData>> searchLocation(String query) async {
    try {
      if (query.isEmpty || query.length < 3) {
        return [];
      }

      List<Location> locations = await locationFromAddress(query);

      if (locations.isEmpty) {
        return [];
      }

      // Convertir cada ubicación a LocationData
      List<LocationData> results = [];
      for (Location location in locations.take(5)) {
        LocationData? data = await reverseGeocode(
          location.latitude,
          location.longitude,
        );
        if (data != null) {
          results.add(data);
        }
      }

      return results;
    } catch (e) {
      print('❌ Error searching location: $e');
      return [];
    }
  }

  List<LocationData> _localLocations = [];

  /// Carga las ubicaciones desde el archivo JSON local
  Future<void> loadLocalLocations() async {
    if (_localLocations.isNotEmpty) return;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/Localizations-AR.json',
      );
      final Map<String, dynamic> data = json.decode(jsonString);

      List<LocationData> loadedLocations = [];

      // Estructura: { "Argentina": { "Provincia": [ { "ciudad": "Nombre", ... } ] } }
      if (data.containsKey('Argentina')) {
        final Map<String, dynamic> provinces = data['Argentina'];

        provinces.forEach((provinceName, citiesList) {
          if (citiesList is List) {
            for (var cityData in citiesList) {
              if (cityData is Map) {
                loadedLocations.add(
                  LocationData(
                    city: cityData['ciudad'] ?? '',
                    state: provinceName,
                    country: 'Argentina',
                    // No tenemos coordenadas en el JSON, se podrían buscar si es necesario
                    // o dejarlas nulas si solo nos importa el texto para guardar
                  ),
                );
              }
            }
          }
        });
      }

      _localLocations = loadedLocations;
      print('✅ Loaded ${_localLocations.length} local locations');
    } catch (e) {
      print('❌ Error loading local locations: $e');
    }
  }

  /// Busca ubicaciones locales por nombre
  List<LocationData> searchLocalLocations(String query) {
    if (query.isEmpty || query.length < 2) return [];

    final normalizedQuery = query.toLowerCase();

    return _localLocations
        .where((location) {
          return location.city.toLowerCase().contains(normalizedQuery) ||
              location.state.toLowerCase().contains(normalizedQuery);
        })
        .take(20)
        .toList(); // Limitamos a 20 resultados
  }

  /// Abre la configuración de ubicación del dispositivo
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Abre la configuración de la app
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
