# 🖼️ Implementación de Sistema de Subida de Imágenes con Cloudinary

## 📋 Resumen

Sistema completo de gestión de imágenes usando Cloudinary para la app de citas Flutter, siguiendo la arquitectura definida en el proyecto React original.

---

## 🎯 Objetivos

1. **Subida de imágenes** a Cloudinary con optimización automática
2. **Crop interactivo** antes de subir (aspect ratio 4:5)
3. **Gestión de fotos** (agregar, eliminar, reordenar)
4. **Límite de 9 fotos** por usuario
5. **Validación de 2 fotos mínimas** para perfil completo
6. **Integración** con edición de perfil y onboarding

---

## 📦 Dependencias Necesarias

### Agregar a `pubspec.yaml`:

```yaml
dependencies:
  # Imágenes (ya instaladas)
  image_picker: ^1.1.2
  image_cropper: ^8.0.2
  
  # Cloudinary
  cloudinary_sdk: ^5.3.0  # SDK oficial de Cloudinary
  
  # HTTP (ya instalado)
  dio: ^5.7.0
  
  # Compresión de imágenes
  flutter_image_compress: ^2.3.0
  
  # Permisos
  permission_handler: ^11.3.1
  
  # Drag & Drop (opcional para reordenar)
  reorderable_grid_view: ^2.2.8
```

---

## 🏗️ Arquitectura de Implementación

### Estructura de Archivos

```
lib/
├── core/
│   └── services/
│       ├── cloudinary_service.dart      # NEW - Servicio de Cloudinary
│       ├── image_manager_service.dart   # NEW - Gestión de imágenes
│       └── firestore_service.dart       # MODIFY - Agregar métodos de fotos
├── presentation/
│   ├── providers/
│   │   └── photos_provider.dart         # NEW - Estado de fotos
│   ├── screens/
│   │   └── profile/
│   │       └── edit_profile_screen.dart # MODIFY - Integrar upload
│   └── widgets/
│       ├── photo_upload_widget.dart     # NEW - Grid de fotos
│       ├── photo_picker_sheet.dart      # NEW - Bottom sheet picker
│       └── photo_item.dart              # NEW - Item individual de foto
```

---

## 🔧 Configuración

### 1. Variables de Entorno

Agregar a `.env`:

```env
# Cloudinary Configuration
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_UPLOAD_PRESET=your_upload_preset
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

### 2. Configuración de Cloudinary

#### Transformaciones Automáticas
- `q_auto` - Calidad automática
- `f_auto` - Formato automático (WebP en navegadores compatibles)
- `c_fill` - Recorte para llenar dimensiones
- Compresión: Máx 1MB
- Dimensiones: Máx 1080px

#### Estructura de Carpetas
```
app-de-citas/users/{uid}/photo_1.jpg
app-de-citas/users/{uid}/photo_2.jpg
...
```

#### Límites
- Máximo: 9 fotos por usuario
- Mínimo: 2 fotos (para perfil completo)

---

## 🔄 Flujo de Subida de Imágenes

```
1. Usuario selecciona imagen
   ↓
2. Crop interactivo con image_cropper (ratio 4:5)
   ↓
3. Compresión automática si excede 1MB
   ↓
4. Validación de dimensiones (máx 1080px)
   ↓
5. Subida a Cloudinary con Upload Preset
   ↓
6. Cloudinary devuelve URL optimizada
   ↓
7. URL se guarda en Firestore /users/{uid}/photos[]
   ↓
8. Actualización inmediata en UI
```

---

## 📝 Implementación por Componentes

### 1. CloudinaryService

**Archivo:** `lib/core/services/cloudinary_service.dart`

**Responsabilidades:**
- Subir imágenes a Cloudinary
- Generar URLs optimizadas con transformaciones
- Eliminar imágenes de Cloudinary
- Validar tamaño y dimensiones

**Métodos principales:**
```dart
class CloudinaryService {
  // Subir imagen y retornar URL
  Future<String> uploadImage(File imageFile, String userId);
  
  // Eliminar imagen por public_id
  Future<void> deleteImage(String publicId);
  
  // Generar URL optimizada
  String getOptimizedUrl(String publicId, {int? width, int? height});
  
  // Validar imagen antes de subir
  Future<bool> validateImage(File imageFile);
}
```

**Transformaciones aplicadas:**
```dart
final transformations = 'q_auto,f_auto,c_fill,w_1080,h_1350';
```

---

### 2. ImageManagerService

**Archivo:** `lib/core/services/image_manager_service.dart`

**Responsabilidades:**
- Seleccionar imagen (cámara/galería)
- Crop interactivo
- Comprimir imagen
- Flujo completo de subida

**Métodos principales:**
```dart
class ImageManagerService {
  // Seleccionar imagen de galería o cámara
  Future<File?> pickImage(ImageSource source);
  
  // Crop interactivo con ratio 4:5
  Future<File?> cropImage(File imageFile);
  
  // Comprimir imagen si excede límite
  Future<File> compressImage(File imageFile, {int maxSizeKB = 1024});
  
  // Flujo completo: pick → crop → compress → upload
  Future<String?> uploadUserPhoto(String userId, ImageSource source);
}
```

---

### 3. PhotosProvider

**Archivo:** `lib/presentation/providers/photos_provider.dart`

**Estado gestionado:**
```dart
class PhotosState {
  List<String> photos;           // URLs de fotos actuales
  bool isLoading;                // Cargando
  double? uploadProgress;        // Progreso de subida (0.0 - 1.0)
  String? error;                 // Error si existe
  int maxPhotos = 9;             // Límite
  int minPhotos = 2;             // Mínimo requerido
}
```

**Métodos:**
```dart
// Agregar nueva foto
Future<void> addPhoto(ImageSource source);

// Eliminar foto
Future<void> removePhoto(int index);

// Reordenar fotos
Future<void> reorderPhotos(int oldIndex, int newIndex);

// Validar si puede agregar más
bool canAddMore();

// Validar si cumple mínimo
bool meetsMinimum();
```

---

### 4. PhotoUploadWidget

**Archivo:** `lib/presentation/widgets/photo_upload_widget.dart`

**Características:**
- Grid 3x3 para mostrar fotos
- Botón "+" para agregar (solo si < 9)
- Preview de fotos existentes
- Botón de eliminar en cada foto
- Drag & drop para reordenar
- Indicador de progreso durante upload
- Contador de fotos (X/9)

**Layout:**
```
┌─────┬─────┬─────┐
│ [+] │ IMG │ IMG │  Fila 1
├─────┼─────┼─────┤
│ IMG │ IMG │ IMG │  Fila 2
├─────┼─────┼─────┤
│ IMG │ IMG │ IMG │  Fila 3
└─────┴─────┴─────┘
```

**Estados visuales:**
- Empty slot: Botón "+" con borde punteado
- Loading: Skeleton loader con progress
- Loaded: Imagen con botón X en esquina
- Error: Icono de error con retry

---

### 5. PhotoPickerSheet

**Archivo:** `lib/presentation/widgets/photo_picker_sheet.dart`

**Opciones:**
1. 📷 **Tomar foto** - Abre cámara
2. 🖼️ **Seleccionar de galería** - Abre galería
3. ❌ **Cancelar** - Cierra sheet

**Diseño:**
- Bottom sheet con bordes redondeados
- Iconos grandes y claros
- Animación de entrada suave
- Tema oscuro consistente

---

## 🔒 Seguridad y Validaciones

### Validaciones Client-Side
- ✅ Tamaño máximo: 1MB por imagen
- ✅ Dimensiones máximas: 1080px
- ✅ Formatos permitidos: JPG, PNG, WebP
- ✅ Límite de 9 fotos
- ✅ Mínimo 2 fotos para perfil completo

### Validaciones Server-Side (Firestore Rules)
```javascript
match /users/{userId} {
  allow update: if request.auth.uid == userId
    && request.resource.data.photos.size() <= 9
    && request.resource.data.photos.size() >= 2;
}
```

### Seguridad Cloudinary
- Upload preset sin firma (unsigned)
- Carpeta específica por usuario: `app-de-citas/users/{uid}/`
- Límite de tamaño configurado en Cloudinary
- Moderación automática (opcional)

---

## 📊 Manejo de Errores

### Errores Comunes

| Error | Causa | Solución |
|-------|-------|----------|
| `permission_denied` | Sin permisos de cámara/galería | Solicitar permisos |
| `file_too_large` | Imagen > 1MB después de comprimir | Mostrar error, pedir otra imagen |
| `upload_failed` | Fallo en Cloudinary | Retry automático (3 intentos) |
| `limit_reached` | Ya tiene 9 fotos | Mostrar mensaje, deshabilitar botón + |
| `network_error` | Sin conexión | Mostrar error, permitir retry |

### Feedback al Usuario
- ✅ Loading spinner durante upload
- ✅ Progress bar (0-100%)
- ✅ Mensaje de éxito con checkmark
- ✅ Mensaje de error con opción de retry
- ✅ Validaciones en tiempo real

---

## 🎨 Diseño y UX

### Animaciones
- Fade in al cargar imagen
- Slide up del bottom sheet
- Scale animation al eliminar
- Smooth reordering con drag & drop

### Estados Visuales
- **Empty**: Botón "+" con borde punteado
- **Loading**: Skeleton con shimmer effect
- **Loaded**: Imagen con overlay al hover
- **Error**: Icono de error con retry button

### Colores
- Primary: `#E94057` (botones principales)
- Background: `#1A1A1A` (fondo)
- Card: `#2A2A2A` (fondo de cards)
- Success: `#4CAF50` (upload exitoso)
- Error: `#F44336` (errores)

---

## 🔄 Integración con Pantallas Existentes

### Edit Profile Screen

**Archivo:** `lib/presentation/screens/profile/edit_profile_screen.dart`

**Cambios:**
1. Agregar `PhotoUploadWidget` en la parte superior
2. Mostrar contador de fotos (X/9)
3. Validar mínimo 2 fotos antes de guardar
4. Mostrar mensaje si no cumple mínimo
5. Deshabilitar botón "Guardar" si < 2 fotos

**Validación al guardar:**
```dart
if (photos.length < 2) {
  showSnackBar('Debes tener al menos 2 fotos en tu perfil');
  return;
}
```

### Onboarding Wizard

**Nuevo paso en wizard:**
- **Paso 1: Fotos** (NUEVO)
  - Título: "Muestra tu mejor versión"
  - Subtítulo: "Agrega al menos 2 fotos"
  - `PhotoUploadWidget`
  - Botón "Continuar" (habilitado solo si >= 2 fotos)
  - Opción "Completar después" (skip temporal)

---

## 📅 Plan de Implementación

### Fase 1: Configuración (Día 1)
- [ ] Agregar dependencias a `pubspec.yaml`
- [ ] Configurar variables de entorno en `.env`
- [ ] Crear estructura de archivos

### Fase 2: Servicios (Día 2-3)
- [ ] Implementar `CloudinaryService`
- [ ] Implementar `ImageManagerService`
- [ ] Actualizar `FirestoreService` con métodos de fotos

### Fase 3: Estado (Día 3)
- [ ] Crear `PhotosProvider`
- [ ] Implementar lógica de estado

### Fase 4: UI (Día 4-5)
- [ ] Crear `PhotoUploadWidget`
- [ ] Crear `PhotoPickerSheet`
- [ ] Integrar Image Cropper

### Fase 5: Integración (Día 6)
- [ ] Integrar con `EditProfileScreen`
- [ ] Integrar con Onboarding
- [ ] Validaciones finales

### Fase 6: Testing (Día 7)
- [ ] Unit tests
- [ ] Widget tests
- [ ] Integration tests
- [ ] Manual testing en dispositivos

---

## ⏱️ Estimación de Tiempo

| Tarea | Tiempo Estimado |
|-------|----------------|
| Configuración y dependencias | 2 horas |
| CloudinaryService | 4 horas |
| ImageManagerService | 4 horas |
| PhotosProvider | 3 horas |
| PhotoUploadWidget | 6 horas |
| PhotoPickerSheet | 2 horas |
| Integración con EditProfile | 3 horas |
| Integración con Onboarding | 4 horas |
| Testing y debugging | 6 horas |
| **TOTAL** | **34 horas (~1 semana)** |

---

## ✅ Criterios de Aceptación

- ✅ Usuario puede agregar hasta 9 fotos
- ✅ Usuario puede eliminar fotos existentes
- ✅ Usuario puede reordenar fotos (drag & drop)
- ✅ Crop interactivo funciona correctamente (4:5 ratio)
- ✅ Imágenes se comprimen automáticamente
- ✅ Imágenes se optimizan en Cloudinary (WebP, q_auto)
- ✅ Validación de mínimo 2 fotos funciona
- ✅ Validación de máximo 9 fotos funciona
- ✅ Progress indicator durante upload
- ✅ Manejo de errores robusto
- ✅ Funciona en Android e iOS
- ✅ Performance óptimo (60 FPS)

---

## 🧪 Testing

### Unit Tests
- [ ] `CloudinaryService.uploadImage()`
- [ ] `CloudinaryService.deleteImage()`
- [ ] `ImageManagerService.compressImage()`
- [ ] `PhotosProvider.addPhoto()`
- [ ] `PhotosProvider.removePhoto()`

### Widget Tests
- [ ] `PhotoUploadWidget` - Renderizado correcto
- [ ] `PhotoPickerSheet` - Opciones visibles
- [ ] Validación de límite de 9 fotos
- [ ] Validación de mínimo 2 fotos

### Integration Tests
- [ ] Flujo completo: seleccionar → crop → upload → guardar
- [ ] Eliminar foto y actualizar Firestore
- [ ] Reordenar fotos
- [ ] Validación en onboarding

### Manual Testing
- [ ] Probar en Android (diferentes versiones)
- [ ] Probar en iOS (diferentes versiones)
- [ ] Probar con imágenes grandes (> 5MB)
- [ ] Probar sin conexión a internet
- [ ] Probar con permisos denegados

---

## 📌 Notas Adicionales

### Optimizaciones Futuras
- Caché de imágenes local
- Upload en background
- Batch upload (múltiples fotos a la vez)
- Detección de rostros para crop automático
- Filtros de imagen (opcional)

### Consideraciones de Performance
- Lazy loading en grids grandes
- Thumbnail generation en Cloudinary
- Caché de URLs optimizadas
- Compresión agresiva antes de upload

---

**Versión**: 1.0  
**Fecha**: Diciembre 2024  
**Estado**: Pendiente de implementación  
**Prioridad**: Alta (requisito para MVP Premium)
