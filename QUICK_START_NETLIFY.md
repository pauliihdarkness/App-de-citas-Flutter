# Quick Start: Deploy to Netlify Free Tier

Esta es una guía rápida para desplegar tu app Flutter en Netlify (plan gratuito).

## 📋 Requisitos Previos

- [ ] Cuenta en [Netlify](https://www.netlify.com/) (gratis)
- [ ] Cuenta en [Firebase](https://firebase.google.com/) (gratis)
- [ ] Repositorio en GitHub/GitLab (opcional pero recomendado)
- [ ] Credenciales de Firebase Web (ver `ENV_VARIABLES_REFERENCE.md`)

## 🚀 Despliegue Rápido (5 pasos)

### 1. Preparar Repositorio

```bash
# Asegúrate de que todo esté commiteado
git add .
git commit -m "Preparar para deploy en Netlify"
git push origin main
```

### 2. Conectar a Netlify

1. Ve a [app.netlify.com](https://app.netlify.com/)
2. Haz clic en **Add new site** → **Import an existing project**
3. Selecciona **GitHub** (o GitLab)
4. Autoriza a Netlify
5. Selecciona tu repositorio

### 3. Configurar Build

Netlify detectará automáticamente `netlify.toml`. Verifica:

- **Build command**: `bash install-flutter.sh && node build-config.js && flutter build web --release --web-renderer canvaskit`
- **Publish directory**: `build/web`
- **Functions directory**: `netlify/functions`

### 4. Configurar Variables de Entorno

**CRÍTICO**: Sin estas variables, la app no funcionará.

1. En Netlify: **Site settings** → **Build & deploy** → **Environment**
2. Haz clic en **Edit variables**
3. Agrega estas 4 variables (mínimo):

```
FIREBASE_WEB_API_KEY = [tu_api_key_de_firebase]
FIREBASE_WEB_APP_ID = [tu_app_id_de_firebase]
FIREBASE_MESSAGING_SENDER_ID = [tu_sender_id]
FIREBASE_PROJECT_ID = [tu_project_id]
```

**¿Dónde obtenerlas?** Ver `ENV_VARIABLES_REFERENCE.md`

### 5. Deploy

1. Haz clic en **Deploy site**
2. Espera 5-10 minutos (primera vez)
3. ¡Listo! Tu app estará en `https://[nombre-random].netlify.app`

## ✅ Verificación

Después del deploy, abre tu sitio y:

1. Presiona **F12** para abrir la consola
2. Deberías ver: `✅ Using build-time injected configuration`
3. Prueba iniciar sesión
4. Verifica que todo funcione

## 🐛 Si Algo Sale Mal

### Build falla con "flutter: command not found"

**Solución**: Asegúrate de que el build command incluya `bash install-flutter.sh`

```toml
# En netlify.toml
[build]
  command = "bash install-flutter.sh && node build-config.js && flutter build web --release --web-renderer canvaskit"
```

### "Environment variables not configured"

**Solución**: 
1. Verifica que las 4 variables de Firebase estén en Netlify
2. Haz un nuevo deploy: **Deploys** → **Trigger deploy**

### Build toma más de 15 minutos (timeout)

**Solución**: Cambia el renderer a HTML (más rápido):

```toml
# En netlify.toml, cambia:
command = "bash install-flutter.sh && node build-config.js && flutter build web --release --web-renderer html"
```

## 📚 Documentación Completa

Para más detalles, consulta:

- **`NETLIFY_DEPLOYMENT_GUIDE.md`** - Guía completa de despliegue
- **`ENV_VARIABLES_REFERENCE.md`** - Referencia de variables de entorno
- **`NETLIFY_CONFIG.md`** - Explicación de la configuración
- **`NETLIFY_ENV_SETUP.md`** - Setup de variables de entorno

## 💡 Tips para Plan Gratuito

1. **Usa caching**: Ya está configurado en `netlify.toml`
2. **Deploy solo cuando sea necesario**: Tienes 300 minutos/mes
3. **Monitorea uso**: **Site settings** → **Usage and billing**
4. **Usa Cloudinary**: Para imágenes (ahorra bandwidth)

## 🎯 Próximos Pasos

- [ ] Configurar dominio personalizado
- [ ] Habilitar Cloudinary para imágenes
- [ ] Configurar notificaciones de deploy
- [ ] Monitorear analytics

---

**¿Necesitas ayuda?** Consulta `NETLIFY_DEPLOYMENT_GUIDE.md` para troubleshooting detallado.
