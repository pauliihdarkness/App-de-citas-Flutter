# Guía de Despliegue en Netlify (Plan Gratuito)

Esta guía te ayudará a desplegar tu aplicación Flutter Web en Netlify usando el **plan gratuito**.

## 📊 Límites del Plan Gratuito de Netlify

- ⏱️ **Build minutes**: 300 minutos/mes
- 📦 **Bandwidth**: 100 GB/mes  
- ⚡ **Serverless Functions**: 125,000 invocaciones/mes
- 🕐 **Build timeout**: 15 minutos máximo por build
- 🌐 **Sites**: Ilimitados

## ✅ Optimizaciones Implementadas

Este proyecto está optimizado para el plan gratuito:

1. **Caching agresivo** - Reduce bandwidth y acelera la carga
2. **Variables inyectadas en build time** - Minimiza uso de Netlify Functions
3. **Build caching** - Reduce tiempo de build (ahorra minutos)
4. **Renderer optimizado** - Usa CanvasKit para mejor rendimiento

---

## 🚀 Pasos para Desplegar

### 1. Crear Cuenta en Netlify

1. Ve a [netlify.com](https://www.netlify.com/)
2. Haz clic en **Sign up** (puedes usar GitHub, GitLab o email)
3. Verifica tu email si es necesario

### 2. Conectar tu Repositorio

#### Opción A: Desde GitHub/GitLab (Recomendado)

1. Sube tu proyecto a GitHub o GitLab
2. En Netlify, haz clic en **Add new site** → **Import an existing project**
3. Selecciona tu proveedor de Git (GitHub/GitLab)
4. Autoriza a Netlify para acceder a tus repositorios
5. Selecciona el repositorio de tu proyecto Flutter

#### Opción B: Deploy Manual (Sin Git)

1. En Netlify, haz clic en **Add new site** → **Deploy manually**
2. Arrastra la carpeta `build/web` después de compilar localmente
3. **Nota**: Esta opción NO es recomendada porque no tendrás CI/CD automático

### 3. Configurar Build Settings

Netlify debería detectar automáticamente la configuración desde `netlify.toml`, pero verifica:

- **Build command**: `node build-config.js && flutter build web --release --web-renderer canvaskit`
- **Publish directory**: `build/web`
- **Functions directory**: `netlify/functions`

### 4. Configurar Variables de Entorno

**IMPORTANTE**: Este es el paso más crítico. Sin estas variables, la app no funcionará.

1. Ve a **Site settings** → **Build & deploy** → **Environment**
2. Haz clic en **Edit variables**
3. Agrega las siguientes variables:

#### Variables de Firebase (Obligatorias)

```
FIREBASE_WEB_API_KEY = AIza...
FIREBASE_WEB_APP_ID = 1:123...
FIREBASE_MESSAGING_SENDER_ID = 123456789
FIREBASE_PROJECT_ID = tu-proyecto-id
```

#### Variables de Cloudinary (Opcionales)

```
CLOUDINARY_CLOUD_NAME = tu_cloud_name
CLOUDINARY_PRESET_NAME = tu_preset_name
```

#### ¿Dónde obtener las credenciales de Firebase?

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Haz clic en ⚙️ **Project Settings**
4. En la pestaña **General**, busca "Your apps"
5. Selecciona tu aplicación web (ícono `</>`)
6. Copia los valores de `firebaseConfig`:
   - `apiKey` → `FIREBASE_WEB_API_KEY`
   - `appId` → `FIREBASE_WEB_APP_ID`
   - `messagingSenderId` → `FIREBASE_MESSAGING_SENDER_ID`
   - `projectId` → `FIREBASE_PROJECT_ID`

### 5. Instalar Flutter en Netlify Build

Netlify necesita instalar Flutter durante el build. Hay dos opciones:

#### Opción A: Usar Build Image con Flutter (Recomendado)

Agrega esto a tu `netlify.toml` (ya está incluido):

```toml
[build.environment]
  NODE_VERSION = "18"
```

Luego, en **Site settings** → **Build & deploy** → **Build settings**, agrega:

**Build image**: `Ubuntu Focal 20.04` (default)

Y en **Environment variables**, agrega:

```
FLUTTER_VERSION = stable
```

#### Opción B: Script de Instalación Manual

Crea un archivo `install-flutter.sh` en la raíz del proyecto:

```bash
#!/bin/bash
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi
export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor
flutter config --enable-web
```

Y modifica el build command en `netlify.toml`:

```toml
command = "bash install-flutter.sh && node build-config.js && flutter build web --release --web-renderer canvaskit"
```

**⚠️ ADVERTENCIA**: Esta opción consume más minutos de build.

### 6. Deploy

1. Haz clic en **Deploy site** (o haz push a tu repositorio si usas Git)
2. Espera a que el build termine (puede tomar 5-10 minutos la primera vez)
3. Netlify te dará una URL temporal como `https://random-name-123.netlify.app`

### 7. Configurar Dominio Personalizado (Opcional)

1. Ve a **Domain settings**
2. Haz clic en **Add custom domain**
3. Sigue las instrucciones para configurar tu dominio

---

## 🔍 Verificación Post-Despliegue

Después del despliegue, verifica que todo funcione:

### Checklist de Verificación

- [ ] La aplicación carga sin errores
- [ ] Abre la consola del navegador (F12)
- [ ] Deberías ver: `✅ Using build-time injected configuration (Netlify Functions not needed)`
- [ ] Firebase se inicializa correctamente
- [ ] Puedes iniciar sesión
- [ ] Las imágenes se cargan
- [ ] El routing funciona (navega entre páginas y recarga)

### Comandos de Consola para Verificar

Abre la consola del navegador (F12) y ejecuta:

```javascript
// Verificar que las variables estén cargadas
console.log(window.__env);

// Deberías ver algo como:
// {
//   FIREBASE_WEB_API_KEY: "AIza...",
//   FIREBASE_WEB_APP_ID: "1:123...",
//   FIREBASE_MESSAGING_SENDER_ID: "123456789",
//   FIREBASE_PROJECT_ID: "tu-proyecto-id",
//   CLOUDINARY_CLOUD_NAME: "...",
//   CLOUDINARY_PRESET_NAME: "..."
// }
```

---

## 🐛 Solución de Problemas

### Error: "Environment variables not configured"

**Síntoma**: En la consola ves `❌ CRITICAL: Environment variables not configured!`

**Solución**:
1. Ve a **Site settings** → **Build & deploy** → **Environment**
2. Verifica que todas las variables de Firebase estén configuradas
3. Haz un nuevo deploy: **Deploys** → **Trigger deploy** → **Deploy site**

### Error: "Flutter command not found"

**Síntoma**: El build falla con `flutter: command not found`

**Solución**:
1. Usa la Opción B del paso 5 (Script de instalación manual)
2. O contacta a Netlify Support para habilitar Flutter en tu build image

### Build toma más de 15 minutos

**Síntoma**: El build se cancela por timeout

**Solución**:
1. Asegúrate de que el caching esté habilitado (ya está en `netlify.toml`)
2. Considera usar `--web-renderer html` en lugar de `canvaskit` (más rápido pero menos rendimiento)
3. Reduce el tamaño de assets en `assets/`

### Error 404 en rutas

**Síntoma**: Al recargar una página que no es `/`, obtienes 404

**Solución**:
- Verifica que `netlify.toml` tenga el redirect configurado (ya está incluido)
- Redeploy el sitio

### Netlify Functions agota el límite

**Síntoma**: Recibes email de Netlify diciendo que agotaste las 125k invocaciones

**Solución**:
- Esto NO debería pasar con la configuración actual
- Las variables se inyectan en build time, no en runtime
- Verifica en la consola que veas: `✅ Using build-time injected configuration`
- Si ves `✅ Environment variables loaded from Netlify Function (fallback)`, hay un problema con `build-config.js`

### Imágenes no cargan / Bandwidth agotado

**Síntoma**: Netlify te notifica que agotaste los 100GB de bandwidth

**Solución**:
1. Usa Cloudinary para almacenar imágenes (ya está configurado en el proyecto)
2. Verifica que las imágenes se suban a Cloudinary, no a Firebase Storage
3. Optimiza imágenes antes de subirlas
4. Considera usar un CDN externo para assets grandes

---

## 💡 Tips para Ahorrar Recursos en Plan Gratuito

### Ahorrar Build Minutes

1. **Usa caching**: Ya está configurado en `netlify.toml`
2. **Deploy solo cuando sea necesario**: No hagas push de cambios menores
3. **Usa deploy previews con cuidado**: Cada PR consume minutos
4. **Considera builds locales**: Sube `build/web` manualmente para pruebas

### Ahorrar Bandwidth

1. **Usa Cloudinary**: Para todas las imágenes de usuarios
2. **Optimiza assets**: Comprime imágenes en `assets/`
3. **Lazy loading**: Ya está implementado en Flutter
4. **Cache headers**: Ya están configurados en `netlify.toml`

### Monitorear Uso

1. Ve a **Site settings** → **Usage and billing**
2. Revisa:
   - Build minutes usados
   - Bandwidth usado
   - Function invocations (debería ser casi 0)

---

## 📚 Recursos Adicionales

- [Documentación de Netlify](https://docs.netlify.com/)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [Firebase Web Setup](https://firebase.google.com/docs/web/setup)
- [Netlify Community](https://answers.netlify.com/)

---

## 🎯 Próximos Pasos

Después de desplegar exitosamente:

1. **Configura dominio personalizado** (opcional)
2. **Habilita HTTPS** (automático en Netlify)
3. **Configura notificaciones de deploy** en Netlify
4. **Monitorea analytics** en Netlify Analytics (gratis)
5. **Configura Firebase Hosting** como alternativa si Netlify no funciona

---

## ⚠️ Limitaciones del Plan Gratuito

Ten en cuenta estas limitaciones:

- **No hay soporte prioritario**: Respuestas pueden tardar días
- **Límite de bandwidth**: 100GB/mes puede ser poco para apps populares
- **Build concurrency**: Solo 1 build a la vez
- **No hay password protection**: Para proteger sitios en desarrollo

Si tu app crece, considera:
- **Netlify Pro**: $19/mes (1TB bandwidth, 25k build minutes)
- **Firebase Hosting**: Alternativa gratuita con límites diferentes
- **Vercel**: Alternativa con plan gratuito generoso

---

¿Necesitas ayuda? Abre un issue en el repositorio o consulta la documentación de Netlify.
