# Configuración de Netlify para la App Flutter

## Descripción del Proceso

Tu aplicación Flutter web ahora usa un sistema de 2 niveles para cargar variables de entorno:

1. **build-config.js** → Genera `web/config.js` con variables inyectadas en build time
2. **Netlify Functions** → Fallback para cargar variables si config.js no tiene valores

## Pasos para Configurar en Netlify

### 1. Obtén tus Credenciales de Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Ve a **Project Settings** (⚙️)
4. En la pestaña **General**, busca la sección de "Tu aplicación web"
5. Copia los valores de:
   - `apiKey` → `FIREBASE_WEB_API_KEY`
   - `appId` → `FIREBASE_WEB_APP_ID`
   - `messagingSenderId` → `FIREBASE_MESSAGING_SENDER_ID`
   - `projectId` → `FIREBASE_PROJECT_ID`

### 2. Configura Variables en Netlify

1. Ve a tu sitio en [Netlify](https://app.netlify.com/)
2. **Site settings** → **Build & deploy** → **Environment**
3. Haz clic en **Edit variables**
4. Agrega las siguientes variables:

```
FIREBASE_WEB_API_KEY = tu_api_key_aqui
FIREBASE_WEB_APP_ID = tu_app_id_aqui
FIREBASE_MESSAGING_SENDER_ID = tu_sender_id_aqui
FIREBASE_PROJECT_ID = tu_project_id_aqui
```

### 3. Redeploy

- Ve a **Deploys**
- Haz clic en **Trigger deploy**
- Selecciona **Deploy site**

## Cómo Funciona

### En Build Time:
1. Netlify ejecuta `build-config.js`
2. El script lee las variables de `process.env`
3. Crea `web/config.js` con las variables inyectadas
4. Flutter compila la app
5. El archivo `web/config.js` se incluye en `build/web`

### En Runtime:
1. El navegador carga `index.html`
2. Se carga `web/config.js` → establece `window.__env`
3. Si `config.js` tiene valores vacíos, la app intenta cargar desde `/.netlify/functions/get-env`
4. Firebase se inicializa con `window.__env`

## Solución de Problemas

### "GET https://appflutter.netlify.app/.netlify/functions/get-env 404"

Esto es **normal y esperado** en producción si `config.js` se generó correctamente con variables.

Para verificar que funciona:

1. Abre la consola del navegador (F12)
2. Ve a **Console**
3. Deberías ver: `✅ Using injected configuration` o `✅ Environment variables loaded from Netlify Function`
4. Si ves `❌ Error initializing environment`, las variables de entorno no están configuradas en Netlify

### Las variables están vacías

1. Verifica que las variables estén en **Netlify Site Settings**
2. Redeploy después de agregar las variables
3. Espera 2-3 minutos a que se propague el build
4. Abre la consola (F12) → **Application** → **Local Storage** para ver si hay valores

### Firebase no inicializa

1. Verifica en la consola que aparezca `window.__env` con valores
2. Si están vacías, es porque Netlify no tiene las variables configuradas
3. Si están completas pero Firebase falla, verifica la Firebase Console

## Variables por Plataforma

### Android/iOS
- Lee de `.env` local usando `flutter_dotenv`
- Necesitas el archivo `.env` en la raíz del proyecto

### Web (Netlify)
- Lee de `window.__env` (inyectado por `build-config.js`)
- Es seguro porque las variables se almacenan en `process.env` de Netlify, no en el código

## Archivos Clave

- `netlify.toml` - Configuración de build de Netlify
- `build-config.js` - Script que genera `web/config.js`
- `web/config.js` - Archivo generado con variables inyectadas
- `web/index.html` - Carga `config.js` y falback a Netlify Functions
- `netlify/functions/get-env.js` - Función Netlify como fallback
