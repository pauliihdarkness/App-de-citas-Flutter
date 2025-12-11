# Configuración de Variables de Entorno en Netlify

Esta guía explica cómo configurar las variables de entorno para Firebase en tu aplicación Flutter web desplegada en Netlify.

## Variables de Entorno Necesarias

Tu aplicación requiere las siguientes variables de entorno de Firebase:

```
FIREBASE_WEB_API_KEY
FIREBASE_WEB_APP_ID
FIREBASE_MESSAGING_SENDER_ID
FIREBASE_PROJECT_ID
```

## Cómo Configurar en Netlify

### Opción 1: A través del Dashboard de Netlify (Recomendado)

1. Ve a tu sitio en Netlify: https://app.netlify.com
2. Ve a **Site settings** → **Build & deploy** → **Environment**
3. Haz clic en **Edit variables**
4. Añade cada variable de entorno necesaria:
   - `FIREBASE_WEB_API_KEY`: Tu clave API de Firebase (encontrada en firebase_options.dart)
   - `FIREBASE_WEB_APP_ID`: El ID de tu aplicación Firebase
   - `FIREBASE_MESSAGING_SENDER_ID`: El ID del remitente de mensajería
   - `FIREBASE_PROJECT_ID`: El ID del proyecto Firebase

### Opción 2: A través de netlify.toml

El archivo `netlify.toml` ya está configurado para compilar tu aplicación. Las variables pueden pasarse durante el despliegue.

### Opción 3: A través de archivo .env.production

Puedes crear un archivo `.env.production` en la raíz del proyecto:

```bash
FIREBASE_WEB_API_KEY=tu_api_key_aqui
FIREBASE_WEB_APP_ID=tu_app_id_aqui
FIREBASE_MESSAGING_SENDER_ID=tu_sender_id_aqui
FIREBASE_PROJECT_ID=tu_project_id_aqui
```

## Cómo Obtener Tus Credenciales de Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Haz clic en Configuración del proyecto (rueda de engranaje)
4. Ve a la pestaña "General"
5. Desplázate hasta la sección "Tus aplicaciones"
6. Busca tu aplicación web
7. Copia la configuración de Firebase (incluye apiKey, appId, messagingSenderId, projectId)

## Cómo Funcionan las Variables en la App

1. **index.html** carga las variables desde la función Netlify (`/.netlify/functions/get-env`)
2. Las variables se almacenan en `window.__env`
3. **firebase_options.dart** accede a estas variables a través de la función `_getEnv()`
4. En plataformas móviles, se usa el archivo `.env` local (para desarrollo)

## Verificación

Para verificar que las variables se cargan correctamente:

1. Abre la consola del navegador (F12)
2. Ejecuta: `console.log(window.__env)`
3. Deberías ver un objeto con tus variables de Firebase

## Solución de Problemas

### Error 404 al cargar assets/.env

Este es un aviso normal en web. La aplicación está configurada para ignorar este error y usar las variables de Netlify.

### Firebase no se inicializa

1. Verifica que todas las variables estén configuradas en Netlify
2. Asegúrate de que los valores no contengan espacios en blanco
3. Recarga la página después de cambiar las variables (puede que Netlify tarde unos minutos en actualizar)

### Variables vacías en la consola

1. Verifica que las variables estén configuradas en Netlify Settings
2. Comprueba que el nombre de las variables sea exacto (case-sensitive)
3. Redespliega el sitio: Ve a **Deploys** → **Trigger deploy**

## Próximos Pasos

1. Configura las variables en Netlify
2. Redespliega tu aplicación
3. Abre tu sitio web y verifica que Firebase se inicializa correctamente
4. Revisa la consola del navegador para ver los logs de inicialización
