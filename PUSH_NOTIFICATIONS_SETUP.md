# Guía de Despliegue de Notificaciones Push

## Resumen

Las notificaciones push están implementadas usando Firebase Cloud Messaging (FCM) y Cloud Functions. Cuando un usuario envía un mensaje, una Cloud Function se dispara automáticamente y envía una notificación push al destinatario.

## Pasos para Activar las Notificaciones

### 1. Verificar Configuración de Firebase

Asegúrate de tener un proyecto de Firebase configurado con:
- ✅ Firebase Authentication habilitado
- ✅ Cloud Firestore habilitado
- ✅ Firebase Cloud Messaging habilitado
- ⚠️ **Blaze Plan** (requerido para Cloud Functions)

### 2. Instalar Firebase CLI

```bash
npm install -g firebase-tools
```

### 3. Autenticarse en Firebase

```bash
firebase login
```

### 4. Inicializar Firebase Functions (solo primera vez)

Desde la raíz del proyecto:

```bash
firebase init functions
```

Selecciona:
- ✅ Use an existing project → Tu proyecto de Firebase
- ✅ JavaScript
- ❌ ESLint (opcional)
- ✅ Install dependencies with npm

### 5. Instalar Dependencias de Functions

```bash
cd functions
npm install
```

### 6. Desplegar Cloud Functions

Desde la raíz del proyecto:

```bash
firebase deploy --only functions
```

O solo la función de notificaciones:

```bash
firebase deploy --only functions:sendMessageNotification
```

### 7. Verificar Despliegue

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto
3. Ve a **Functions** en el menú lateral
4. Deberías ver `sendMessageNotification` listada

### 8. Probar las Notificaciones

1. **Abre la app en dos dispositivos/emuladores** (o usa dos cuentas)
2. **Inicia sesión** con usuarios diferentes en cada dispositivo
3. **Crea un match** entre los dos usuarios
4. **Envía un mensaje** desde el Usuario A
5. **Verifica** que el Usuario B reciba la notificación push

## Configuración del Cliente (Ya Implementada)

El cliente Flutter ya está configurado con:

✅ `NotificationService` - Maneja FCM y notificaciones locales  
✅ Token management - Guarda/actualiza tokens en Firestore  
✅ Navigation handler - Navega al chat al tocar notificación  
✅ Android permissions - Permisos de notificaciones configurados  
✅ Notification channels - Canal "chat_messages" configurado  

## Estructura de Firestore Requerida

### Tokens FCM
```
users/{userId}/private/fcmTokens
{
  tokens: ["fcm_token_1", "fcm_token_2"],
  updatedAt: Timestamp
}
```

Los tokens se guardan automáticamente cuando:
- El usuario inicia sesión
- El token se actualiza/refresca

### Matches
```
matches/{matchId}
{
  users: ["userId1", "userId2"],
  lastMessage: "Hola!",
  lastMessageTime: Timestamp,
  unreadCount: {
    "userId1": 0,
    "userId2": 1
  }
}
```

### Messages
```
matches/{matchId}/messages/{messageId}
{
  senderId: "userId",
  text: "Hola!",
  timestamp: Timestamp,
  read: false
}
```

## Monitoreo y Debugging

### Ver Logs de Cloud Functions

```bash
firebase functions:log --only sendMessageNotification
```

### Ver Logs en Tiempo Real

```bash
firebase functions:log --only sendMessageNotification --follow
```

### Logs en Firebase Console

1. Firebase Console → Functions → Logs
2. Filtra por función: `sendMessageNotification`

## Troubleshooting

### ❌ "Billing account not configured"
**Solución:** Habilita el Blaze Plan en Firebase Console

### ❌ Notificaciones no llegan
**Verificar:**
1. ✅ Cloud Function desplegada correctamente
2. ✅ Usuario tiene tokens FCM guardados en Firestore
3. ✅ Permisos de notificaciones concedidos en el dispositivo
4. ✅ App tiene conexión a internet
5. ✅ Logs de Cloud Function no muestran errores

### ❌ Error: "messaging/invalid-registration-token"
**Solución:** La Cloud Function limpia automáticamente tokens inválidos. Esto es normal cuando:
- Usuario desinstala la app
- Usuario borra datos de la app
- Token expira

### ⚠️ Notificaciones solo funcionan en foreground
**Causa:** Cloud Functions no están desplegadas  
**Solución:** Ejecuta `firebase deploy --only functions`

## Costos Estimados

Con el **Blaze Plan**, Cloud Functions incluye:
- 2M invocaciones gratis/mes
- 400K GB-segundos gratis/mes
- 200K CPU-segundos gratis/mes

Para una app de citas con tráfico moderado (<10K usuarios activos), probablemente permanecerás en el tier gratuito.

## Próximos Pasos Opcionales

1. **Notificaciones programadas** - Recordatorios de matches
2. **Notificaciones de match** - Cuando dos usuarios se gustan
3. **Notificaciones de perfil** - Cuando alguien ve tu perfil
4. **Rich notifications** - Imágenes en notificaciones
5. **Action buttons** - Responder desde la notificación

## Soporte

Si encuentras problemas:
1. Revisa los logs: `firebase functions:log`
2. Verifica la configuración en Firebase Console
3. Asegúrate de que el Blaze Plan esté activo
4. Revisa los permisos de notificaciones en el dispositivo
