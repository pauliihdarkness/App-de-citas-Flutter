# App de Citas - Flutter

Una aplicación de citas moderna estilo Tinder construida con Flutter, Firebase y Riverpod.

## 📱 Descripción

Aplicación móvil de citas que permite a los usuarios:
- Crear y gestionar perfiles personalizados
- Descubrir personas compatibles mediante un sistema de swipe
- Hacer match con otros usuarios
- Visualizar perfiles detallados con galería de fotos
- Sistema de verificación de perfiles (en desarrollo)

## 🎨 Características Principales

### Sistema de Swipe
- **Tarjetas deslizables** con efecto Tinder usando `appinio_swiper`
- **Navegación de fotos** mediante zonas táctiles (izquierda/derecha)
- **Botones de acción**: Like (corazón) y Pass (X)
- **Indicadores visuales** de progreso de fotos

### Perfiles de Usuario
- **Vista de tarjeta** en el feed principal con:
  - Galería de fotos navegable
  - Nombre, edad y ubicación
  - Vista previa de biografía
  - Badge de verificación
  - Botón de información para ver perfil completo

- **Vista detallada** del perfil con:
  - Galería de fotos con transiciones suaves
  - Información completa del usuario
  - Intereses y hobbies
  - Información laboral y educativa
  - Estilo de vida (altura, ejercicio, hábitos)
  - Botones de acción integrados

### Sistema de Matches
- **Detección automática** de coincidencias mutuas
- **Diálogo de match** con animación
- **Navegación** al chat (próximamente)

### Autenticación
- **Google Sign-In** integrado
- **Firebase Authentication** para gestión de usuarios
- **Persistencia de sesión**

## 🏗️ Arquitectura

### Estructura del Proyecto

```
lib/
├── config/
│   ├── router.dart          # Configuración de rutas con GoRouter
│   └── theme.dart           # Tema y colores de la aplicación
├── data/
│   ├── models/
│   │   └── user_model.dart  # Modelo de datos de usuario
│   └── services/
│       └── firestore_service.dart  # Servicio de Firestore
├── presentation/
│   ├── providers/
│   │   ├── auth_provider.dart      # Provider de autenticación
│   │   └── users_provider.dart     # Provider de usuarios
│   ├── screens/
│   │   ├── auth/
│   │   │   └── login_screen.dart   # Pantalla de login
│   │   ├── home/
│   │   │   └── home_screen.dart    # Feed principal
│   │   └── profile/
│   │       └── user_detail_screen.dart  # Perfil completo
│   └── widgets/
│       ├── action_button.dart      # Botón de acción reutilizable
│       └── profile_card.dart       # Tarjeta de perfil
└── main.dart
```

### Patrones de Diseño

- **Provider Pattern** con Riverpod para gestión de estado
- **Repository Pattern** para acceso a datos
- **Widget Composition** para componentes reutilizables
- **Async/Await** para operaciones asíncronas

## 🛠️ Tecnologías

### Framework y Lenguaje
- **Flutter** 3.10.1+
- **Dart** 3.10.1+

### Backend y Base de Datos
- **Firebase Core** 3.8.1
- **Firebase Auth** 5.3.3
- **Cloud Firestore** 5.5.2
- **Firebase Storage** 12.3.7
- **Firebase Messaging** 15.1.5

### Gestión de Estado
- **Flutter Riverpod** 2.6.1

### Navegación
- **GoRouter** 14.6.2

### UI/UX
- **Lucide Icons** 0.257.0
- **Google Fonts** 6.2.1
- **Appinio Swiper** 2.1.1 (efecto Tinder)
- **Flutter Animate** 4.5.0
- **Cached Network Image** 3.4.1

### Autenticación
- **Google Sign In** 6.2.2

### Utilidades
- **Flutter Dotenv** 5.2.1
- **UUID** 4.5.2
- **Intl** 0.20.1
- **Shared Preferences** 2.3.3

## 🎨 Diseño y Tema

### Paleta de Colores

```dart
class AppColors {
  static const primary = Color(0xFFE94057);      // Rosa vibrante
  static const secondary = Color(0xFF8A2387);    // Púrpura
  static const accent = Color(0xFF27A9E1);       // Azul
  static const background = Color(0xFF1A1A1A);   // Negro suave
  static const cardBg = Color(0xFF2A2A2A);       // Gris oscuro
  static const textPrimary = Color(0xFFFFFFFF);  // Blanco
  static const textSecondary = Color(0xFFB0B0B0); // Gris claro
}
```

### Características de Diseño
- **Modo oscuro** por defecto
- **Gradientes** en elementos destacados
- **Sombras suaves** para profundidad
- **Bordes redondeados** (24px)
- **Animaciones fluidas** (300-400ms)
- **Transiciones suaves** con curvas personalizadas

## 📊 Modelo de Datos

### UserModel

```dart
{
  uid: String,
  email: String,
  name: String,
  age: int,
  gender: String,
  bio: String,
  photos: List<String>,
  interests: List<String>,
  location: {
    city: String,
    state: String,
    country: String,
    coordinates: GeoPoint
  },
  job: {
    title: String,
    company: String,
    education: String
  },
  lifestyle: {
    height: String,
    workout: String,
    drink: String,
    smoke: String
  },
  preferences: {
    minAge: int,
    maxAge: int,
    maxDistance: int,
    interestedIn: String
  },
  verified: bool,
  createdAt: Timestamp,
  lastActive: Timestamp
}
```

## 🔥 Firebase

### Colecciones de Firestore

- **users**: Perfiles de usuario
- **likes**: Registro de likes/passes
- **matches**: Coincidencias mutuas
- **chats**: Conversaciones (próximamente)
- **messages**: Mensajes (próximamente)

### Reglas de Seguridad

Ver `firestore-structure.md` para la estructura completa de la base de datos y reglas de seguridad.

## 🚀 Instalación

### Prerrequisitos

- Flutter SDK 3.10.1 o superior
- Dart 3.10.1 o superior
- Android Studio / Xcode
- Cuenta de Firebase

### Pasos

1. **Clonar el repositorio**
```bash
git clone <repository-url>
cd app_citas
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar Firebase**
   - Crear proyecto en [Firebase Console](https://console.firebase.google.com)
   - Descargar `google-services.json` (Android) y `GoogleService-Info.plist` (iOS)
   - Colocar archivos en las carpetas correspondientes

4. **Configurar variables de entorno**
   - Copiar `.env.example` a `.env`
   - Completar con las credenciales de Firebase

5. **Ejecutar la aplicación**
```bash
flutter run
```

## 📝 Configuración de Entorno

Crear archivo `.env` en la raíz del proyecto:

```env
# Firebase Configuration
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=your_auth_domain
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_storage_bucket
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id
FIREBASE_MEASUREMENT_ID=your_measurement_id

# Google Sign-In
GOOGLE_CLIENT_ID=your_google_client_id
```

## 🎯 Funcionalidades Implementadas

- ✅ Autenticación con Google
- ✅ Sistema de swipe con tarjetas
- ✅ Navegación de fotos en tarjetas
- ✅ Vista detallada de perfiles
- ✅ Sistema de likes/passes
- ✅ Detección de matches
- ✅ Diálogo de coincidencia
- ✅ Badges de verificación (UI)
- ✅ Animaciones y transiciones suaves
- ✅ Gestión de estado con Riverpod
- ✅ Navegación con GoRouter

## 🚧 Próximas Funcionalidades

- ⏳ Sistema de chat en tiempo real
- ⏳ Verificación de perfiles
- ⏳ Edición de perfil
- ⏳ Subida de fotos
- ⏳ Filtros de búsqueda
- ⏳ Notificaciones push
- ⏳ Reportar usuarios
- ⏳ Bloquear usuarios
- ⏳ Super likes

## 🎨 Componentes Principales

### ProfileCard
Tarjeta de perfil en el feed principal con:
- Galería de fotos navegable
- Información básica del usuario
- Badge de verificación
- Botón de información

### UserDetailScreen
Vista completa del perfil con:
- Galería de fotos con transiciones suaves
- Información detallada
- Botones de acción (Like/Pass)
- Scroll suave

### ActionButton
Botón de acción reutilizable con:
- Diseño circular
- Sombras personalizadas
- Iconos personalizables
- Tamaños variables

## 🔄 Flujo de Navegación

```
LoginScreen
    ↓
HomeScreen (Feed)
    ↓
ProfileCard → UserDetailScreen
    ↓
Like/Pass → Match Dialog → Chat (próximamente)
```

## 📱 Plataformas Soportadas

- ✅ Android
- ✅ iOS
- ✅ Web
- ⏳ Windows
- ⏳ macOS
- ⏳ Linux

## 🤝 Contribución

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto es privado y no está publicado bajo ninguna licencia de código abierto.

## 👥 Autores

- **Tu Nombre** - Desarrollo principal

## 🙏 Agradecimientos

- Inspirado en aplicaciones de citas modernas
- Diseño basado en las mejores prácticas de UI/UX
- Comunidad de Flutter por las excelentes librerías

---

**Versión**: 1.0.0  
**Última actualización**: Diciembre 2024
