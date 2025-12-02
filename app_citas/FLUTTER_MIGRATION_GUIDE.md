# Guía de Migración a Flutter: App de Citas

Este documento detalla los pasos, dependencias y estructura necesaria para recrear la aplicación de citas (actualmente en React) utilizando **Flutter** para Android.

## 1. Configuración del Proyecto

### Crear el proyecto
Ejecuta el siguiente comando para iniciar un nuevo proyecto Flutter:

```bash
flutter create app_citas
cd app_citas
```

### Estructura de Carpetas Sugerida
Organiza tu código en `lib/` siguiendo una arquitectura limpia (ej. Clean Architecture o Feature-based):

```
lib/
├── config/
│   ├── theme.dart           # Definición de colores y temas
│   └── routes.dart          # Configuración de rutas (GoRouter)
├── core/
│   ├── constants/           # Constantes globales
│   ├── utils/               # Utilidades (validadores, formatters)
│   └── services/            # Servicios globales (Socket, HTTP)
├── data/
│   ├── models/              # Modelos de datos (User, Message)
│   ├── repositories/        # Implementación de repositorios
│   └── datasources/         # Fuentes de datos (Firebase, API)
├── domain/
│   ├── entities/            # Entidades de negocio
│   └── repositories/        # Interfaces de repositorios
├── presentation/
│   ├── widgets/             # Widgets reutilizables (Botones, Inputs)
│   ├── screens/             # Pantallas de la app
│   │   ├── auth/            # Login, Registro
│   │   ├── home/            # Feed de usuarios (Swipe)
│   │   ├── chat/            # Lista de chats y sala de chat
│   │   ├── profile/         # Perfil de usuario y edición
│   │   └── splash/          # Pantalla de carga
│   └── providers/           # Gestión de estado (Riverpod/Bloc/Provider)
└── main.dart                # Punto de entrada
```

---

## 2. Dependencias (pubspec.yaml)

Agrega las siguientes dependencias en tu archivo `pubspec.yaml` para replicar las funcionalidades de React:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase (Equivalente a firebase)
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
  firebase_messaging: ^14.7.9 # Para FCM

  # Gestión de Estado (Recomendado: Riverpod o Bloc)
  flutter_riverpod: ^2.4.9

  # Navegación (Equivalente a react-router-dom)
  go_router: ^13.1.0

  # Red y APIs (Equivalente a axios y socket.io-client)
  dio: ^5.4.0
  socket_io_client: ^2.0.3+1

  # UI y Diseño
  google_fonts: ^6.1.0 # Para usar la fuente 'Outfit'
  flutter_svg: ^2.0.9
  lucide_icons: ^0.3.0 # Equivalente a lucide-react (o usar feather_icons)
  
  # Funcionalidades Específicas
  appinio_swiper: ^2.0.0 # Equivalente a react-swipeable (Efecto Tinder)
  image_picker: ^1.0.7 # Selección de imágenes
  image_cropper: ^5.0.1 # Equivalente a react-easy-crop
  shared_preferences: ^2.2.2 # Equivalente a localforage (Storage simple)
  cached_network_image: ^3.3.1 # Optimización de imágenes
  flutter_animate: ^4.5.0 # Animaciones sencillas

  # Utilidades
  intl: ^0.19.0 # Formato de fechas
  uuid: ^4.3.3
```

---

## 3. Diseño y Estilos (Theme)

Basado en `global.css`, aquí tienes la configuración del tema para `lib/config/theme.dart`.

### Paleta de Colores
| Variable CSS | Color Hex | Nombre en Flutter |
|--------------|-----------|-------------------|
| `--primary-color` | `#FE3C72` | `AppColors.primary` |
| `--secondary-color` | `#FF7854` | `AppColors.secondary` |
| `--accent-color` | `#FFC107` | `AppColors.accent` |
| `--text-color` | `#FFFFFF` | `AppColors.textPrimary` |
| `--text-secondary` | `#B0B0B0` | `AppColors.textSecondary` |
| `--background-color` | `#0F0F15` | `AppColors.background` |

### Implementación del Tema (Dart)

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFFFE3C72);
  static const Color secondary = Color(0xFFFF7854);
  static const Color accent = Color(0xFFFFC107);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color background = Color(0xFF0F0F15);
  static const Color glassBg = Color.fromRGBO(255, 255, 255, 0.05);
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.primary,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.background,
    background: AppColors.background,
  ),
  textTheme: GoogleFonts.outfitTextTheme(
    ThemeData.dark().textTheme,
  ).apply(
    bodyColor: AppColors.textPrimary,
    displayColor: AppColors.textPrimary,
  ),
  // Estilo para Inputs
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.glassBg,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    hintStyle: TextStyle(color: AppColors.textSecondary),
  ),
  // Estilo para Botones
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    ),
  ),
);
```

---

## 4. Implementación de Funcionalidades

### A. Autenticación (Firebase Auth)
- **React**: `AuthContext` + `firebase/auth`
- **Flutter**: Usa `FirebaseAuth.instance`.
- **Pantallas**: LoginScreen, RegisterScreen.
- **Lógica**: Crea un `AuthProvider` que escuche `authStateChanges` para redirigir al usuario al `Login` o al `Home`.

### B. Feed de Usuarios (Swipe)
- **React**: `react-swipeable`
- **Flutter**: Usa el paquete `appinio_swiper`.
- **Implementación**:
  - Crea un widget `UserCard` que reciba un modelo `User`.
  - Envuelve las tarjetas en `AppinioSwiper`.
  - Maneja los eventos `onSwipe` (izquierda = dislike, derecha = like).

### C. Chat en Tiempo Real (Socket.io)
- **React**: `socket.io-client`
- **Flutter**: Usa `socket_io_client`.
- **Servicio**:
  ```dart
  // lib/core/services/socket_service.dart
  import 'package:socket_io_client/socket_io_client.dart' as IO;

  class SocketService {
    late IO.Socket socket;

    void connect() {
      socket = IO.io('TU_URL_DEL_BACKEND', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });
      socket.connect();
    }
    // Métodos para emitir y escuchar eventos
  }
  ```

### D. Perfil y Edición
- **Subida de Imágenes**: Usa `image_picker` para seleccionar de la galería/cámara y `image_cropper` para recortar (similar a `react-easy-crop`).
- **Storage**: Sube las imágenes a Firebase Storage usando `putFile`.

### E. Notificaciones (FCM)
- Configura `firebase_messaging` en Flutter.
- Necesitarás configurar los archivos `google-services.json` en `android/app`.

### F. Machine Learning (NSFW)
- **React**: `nsfwjs` (TensorFlow.js)
- **Flutter**: Esto es más complejo en móvil nativo.
  - **Opción 1 (Recomendada)**: Mueve la validación al Backend (Cloud Functions) para no sobrecargar el móvil.
  - **Opción 2**: Usa `tflite_flutter` con un modelo `.tflite` de clasificación de imágenes NSFW.

---

## 5. Pasos para la Migración

1.  **Backend**: Asegúrate de que tu backend (Node.js/Socket.io) permita conexiones desde el emulador/dispositivo móvil (CORS, IP accesible).
2.  **Firebase**:
    - Crea una nueva app **Android** en tu consola de Firebase.
    - Descarga el `google-services.json` y colócalo en `android/app/`.
3.  **Assets**:
    - Copia las imágenes de `client/src/assets/images` a `assets/images` en Flutter.
    - Decláralas en `pubspec.yaml`.
4.  **Desarrollo**:
    - Comienza por la capa de **Autenticación**.
    - Sigue con la **Navegación** y el **Layout Base**.
    - Implementa el **Feed** y la lógica de Swipe.
    - Finalmente, integra el **Chat** y las **Notificaciones**.

---

## 6. Notas Adicionales
- **Glassmorphism**: En Flutter, usa `BackdropFilter` con `ImageFilter.blur` y colores con opacidad para lograr el efecto "glass" definido en tu CSS.
- **Iconos**: `lucide-react` no tiene puerto directo oficial idéntico, pero `lucide_icons` en pub.dev es muy similar.
