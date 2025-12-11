# Variables de Entorno - Referencia Completa

Esta guía documenta todas las variables de entorno necesarias para ejecutar la aplicación.

## 📋 Variables Requeridas

### Firebase Web (Obligatorias para Web)

Estas variables son **obligatorias** para que la aplicación web funcione en Netlify:

| Variable | Descripción | Ejemplo | Dónde Obtenerla |
|----------|-------------|---------|-----------------|
| `FIREBASE_WEB_API_KEY` | Clave API de Firebase para Web | `AIzaSyC...` | Firebase Console → Project Settings → Web App Config |
| `FIREBASE_WEB_APP_ID` | ID de la aplicación web de Firebase | `1:123456789:web:abc...` | Firebase Console → Project Settings → Web App Config |
| `FIREBASE_MESSAGING_SENDER_ID` | ID del remitente para FCM | `123456789` | Firebase Console → Project Settings → Web App Config |
| `FIREBASE_PROJECT_ID` | ID del proyecto de Firebase | `mi-proyecto-123` | Firebase Console → Project Settings → General |

### Firebase Android (Solo para compilación Android)

Estas variables son necesarias solo si compilas la app para Android:

| Variable | Descripción | Ejemplo | Dónde Obtenerla |
|----------|-------------|---------|-----------------|
| `FIREBASE_ANDROID_API_KEY` | Clave API de Firebase para Android | `AIzaSyD...` | Firebase Console → Project Settings → Android App Config |
| `FIREBASE_ANDROID_APP_ID` | ID de la aplicación Android de Firebase | `1:123456789:android:xyz...` | Firebase Console → Project Settings → Android App Config |

### Firebase iOS (Solo para compilación iOS)

Estas variables son necesarias solo si compilas la app para iOS:

| Variable | Descripción | Ejemplo | Dónde Obtenerla |
|----------|-------------|---------|-----------------|
| `FIREBASE_IOS_API_KEY` | Clave API de Firebase para iOS | `AIzaSyE...` | Firebase Console → Project Settings → iOS App Config |
| `FIREBASE_IOS_APP_ID` | ID de la aplicación iOS de Firebase | `1:123456789:ios:def...` | Firebase Console → Project Settings → iOS App Config |

### Firebase macOS (Solo para compilación macOS)

Estas variables son necesarias solo si compilas la app para macOS:

| Variable | Descripción | Ejemplo | Dónde Obtenerla |
|----------|-------------|---------|-----------------|
| `FIREBASE_MACOS_API_KEY` | Clave API de Firebase para macOS | `AIzaSyF...` | Firebase Console → Project Settings → macOS App Config |
| `FIREBASE_MACOS_APP_ID` | ID de la aplicación macOS de Firebase | `1:123456789:macos:ghi...` | Firebase Console → Project Settings → macOS App Config |

### Cloudinary (Opcional pero Recomendado)

Estas variables son opcionales pero **altamente recomendadas** para manejar imágenes de usuarios:

| Variable | Descripción | Ejemplo | Dónde Obtenerla |
|----------|-------------|---------|-----------------|
| `CLOUDINARY_CLOUD_NAME` | Nombre de tu cloud en Cloudinary | `mi-cloud` | Cloudinary Dashboard → Account Details |
| `CLOUDINARY_PRESET_NAME` | Preset de upload configurado | `mi_preset` | Cloudinary Dashboard → Settings → Upload → Upload presets |
| `CLOUDINARY_URL_STORAGE` | URL base de Cloudinary API | `https://api.cloudinary.com/v1_1/` | Valor fijo (ya está en `.env.example`) |

---

## 🔍 Cómo Obtener las Credenciales

### Firebase

#### Paso 1: Acceder a Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Inicia sesión con tu cuenta de Google
3. Selecciona tu proyecto (o créalo si no existe)

#### Paso 2: Obtener Credenciales Web

1. Haz clic en el ícono de ⚙️ **Project Settings** (Configuración del proyecto)
2. Ve a la pestaña **General**
3. Desplázate hasta la sección **Your apps** (Tus aplicaciones)
4. Si no tienes una app web, haz clic en el ícono `</>` para crear una
5. Copia los valores del objeto `firebaseConfig`:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyC...",              // → FIREBASE_WEB_API_KEY
  authDomain: "...",
  projectId: "mi-proyecto-123",      // → FIREBASE_PROJECT_ID
  storageBucket: "...",
  messagingSenderId: "123456789",    // → FIREBASE_MESSAGING_SENDER_ID
  appId: "1:123456789:web:abc...",   // → FIREBASE_WEB_APP_ID
  measurementId: "..."
};
```

#### Paso 3: Obtener Credenciales Android/iOS/macOS (si aplica)

1. En **Project Settings** → **General**
2. Busca tu app de Android/iOS/macOS en **Your apps**
3. Haz clic en la app correspondiente
4. Copia los valores de `apiKey` y `appId`

### Cloudinary

#### Paso 1: Crear Cuenta en Cloudinary

1. Ve a [Cloudinary](https://cloudinary.com/)
2. Haz clic en **Sign Up** (puedes usar el plan gratuito)
3. Verifica tu email

#### Paso 2: Obtener Cloud Name

1. En el Dashboard de Cloudinary
2. En la parte superior verás **Account Details**
3. Copia el valor de **Cloud name**

#### Paso 3: Crear Upload Preset

1. Ve a **Settings** (⚙️) → **Upload**
2. Desplázate hasta **Upload presets**
3. Haz clic en **Add upload preset**
4. Configura:
   - **Preset name**: Elige un nombre (ej: `app_citas_uploads`)
   - **Signing mode**: Unsigned (para uploads desde el cliente)
   - **Folder**: (opcional) Carpeta donde se guardarán las imágenes
5. Haz clic en **Save**
6. Copia el nombre del preset

---

## 🛠️ Configuración por Entorno

### Desarrollo Local

Para desarrollo local, crea un archivo `.env` en la raíz del proyecto:

```bash
# Copia .env.example a .env
cp .env.example .env
```

Luego edita `.env` con tus credenciales:

```env
# Firebase Web
FIREBASE_WEB_API_KEY=AIzaSyC...
FIREBASE_WEB_APP_ID=1:123456789:web:abc...
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_PROJECT_ID=mi-proyecto-123

# Firebase Android (si compilas para Android)
FIREBASE_ANDROID_API_KEY=AIzaSyD...
FIREBASE_ANDROID_APP_ID=1:123456789:android:xyz...

# Cloudinary (opcional)
CLOUDINARY_CLOUD_NAME=mi-cloud
CLOUDINARY_PRESET_NAME=mi_preset
CLOUDINARY_URL_STORAGE=https://api.cloudinary.com/v1_1/
```

**⚠️ IMPORTANTE**: El archivo `.env` está en `.gitignore` y **NO** debe subirse a Git.

### Netlify (Producción Web)

Para Netlify, configura las variables en el Dashboard:

1. Ve a tu sitio en [Netlify](https://app.netlify.com/)
2. **Site settings** → **Build & deploy** → **Environment**
3. Haz clic en **Edit variables**
4. Agrega **solo las variables de Web**:
   - `FIREBASE_WEB_API_KEY`
   - `FIREBASE_WEB_APP_ID`
   - `FIREBASE_MESSAGING_SENDER_ID`
   - `FIREBASE_PROJECT_ID`
   - `CLOUDINARY_CLOUD_NAME` (opcional)
   - `CLOUDINARY_PRESET_NAME` (opcional)

**No necesitas** configurar las variables de Android/iOS/macOS en Netlify.

### Android Build

Para compilar Android, asegúrate de tener el archivo `.env` con las variables de Android:

```env
FIREBASE_ANDROID_API_KEY=AIzaSyD...
FIREBASE_ANDROID_APP_ID=1:123456789:android:xyz...
```

### iOS/macOS Build

Para compilar iOS o macOS, asegúrate de tener el archivo `.env` con las variables correspondientes.

---

## 🔒 Seguridad

### Variables Sensibles

Aunque estas variables se exponen en el cliente (navegador), son **seguras** porque:

1. **Firebase**: Las reglas de seguridad de Firestore/Storage protegen los datos
2. **Cloudinary**: El preset unsigned solo permite uploads, no deletes
3. **No hay secrets**: No estamos exponiendo claves privadas o tokens de admin

### Buenas Prácticas

1. **Nunca subas `.env` a Git**: Ya está en `.gitignore`
2. **Usa Firebase Security Rules**: Protege tus datos en Firestore
3. **Configura Cloudinary Upload Presets**: Limita tamaño y tipo de archivos
4. **Rota credenciales si se comprometen**: Puedes regenerar API keys en Firebase

---

## ✅ Validación

### Verificar Variables en Desarrollo Local

Ejecuta la app en modo debug y verifica en la consola:

```bash
flutter run -d chrome
```

En la consola del navegador deberías ver:

```
📦 Environment configuration loaded: {
  firebase: {
    projectId: "mi-proyecto-123",
    apiKey: "✅ Set",
    appId: "✅ Set",
    messagingSenderId: "✅ Set"
  },
  cloudinary: {
    cloudName: "✅ Set",
    preset: "✅ Set"
  }
}
```

### Verificar Variables en Netlify

Después de desplegar, abre tu sitio y verifica en la consola del navegador:

```javascript
console.log(window.__env);
```

Deberías ver todas las variables configuradas.

---

## 🐛 Troubleshooting

### Error: "Missing Firebase environment variables"

**Causa**: No configuraste las variables en Netlify o `.env`

**Solución**:
1. Verifica que las variables estén en Netlify Dashboard
2. Verifica que `.env` exista en desarrollo local
3. Redeploy en Netlify después de agregar variables

### Error: "Firebase project not found"

**Causa**: `FIREBASE_PROJECT_ID` es incorrecto

**Solución**:
1. Ve a Firebase Console
2. Verifica el Project ID en Project Settings
3. Actualiza la variable

### Cloudinary uploads fallan

**Causa**: Preset no configurado o cloud name incorrecto

**Solución**:
1. Verifica que el preset sea **unsigned**
2. Verifica que el cloud name sea correcto
3. Verifica que el preset exista en Cloudinary Dashboard

---

## 📚 Referencias

- [Firebase Web Setup](https://firebase.google.com/docs/web/setup)
- [Cloudinary Upload Presets](https://cloudinary.com/documentation/upload_presets)
- [Netlify Environment Variables](https://docs.netlify.com/configure-builds/environment-variables/)
- [Flutter Environment Variables](https://pub.dev/packages/flutter_dotenv)
