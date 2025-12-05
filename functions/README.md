# Firebase Cloud Functions - Push Notifications

Este directorio contiene las Cloud Functions para enviar notificaciones push cuando se reciben nuevos mensajes.

## Estructura

```
functions/
├── index.js          # Funciones principales
├── package.json      # Dependencias
└── .gitignore        # Archivos a ignorar
```

## Funciones Implementadas

### `sendMessageNotification`
Trigger: Se dispara cuando se crea un nuevo mensaje en `matches/{matchId}/messages/{messageId}`

**Funcionalidad:**
1. Obtiene información del remitente y destinatario
2. Recupera los tokens FCM del destinatario desde Firestore
3. Envía notificación push con:
   - Título: Nombre del remitente
   - Cuerpo: Texto del mensaje
   - Imagen: Foto del remitente (si está disponible)
   - Data: ID de conversación para navegación
4. Limpia automáticamente tokens inválidos

## Requisitos Previos

1. **Node.js 18+** instalado
2. **Firebase CLI** instalado:
   ```bash
   npm install -g firebase-tools
   ```
3. **Firebase Project** con Blaze Plan (requerido para Cloud Functions)
4. **Autenticación** en Firebase CLI:
   ```bash
   firebase login
   ```

## Instalación

1. Navegar al directorio de functions:
   ```bash
   cd functions
   ```

2. Instalar dependencias:
   ```bash
   npm install
   ```

## Despliegue

### Inicializar Firebase (solo primera vez)

Si aún no has inicializado Firebase en el proyecto:

```bash
# Desde la raíz del proyecto (App Flutter/)
firebase init functions
```

Selecciona:
- Use an existing project → Selecciona tu proyecto de Firebase
- Language → JavaScript
- ESLint → No (opcional)
- Install dependencies → Yes

### Desplegar Functions

```bash
# Desde la raíz del proyecto o desde functions/
firebase deploy --only functions
```

Para desplegar solo una función específica:
```bash
firebase deploy --only functions:sendMessageNotification
```

## Testing Local

### Emulador de Functions

```bash
# Desde functions/
npm run serve
```

Esto iniciará el emulador local en `http://localhost:5001`

### Ver Logs en Tiempo Real

```bash
firebase functions:log --only sendMessageNotification
```

## Monitoreo

### Ver logs en Firebase Console
1. Ir a [Firebase Console](https://console.firebase.google.com)
2. Seleccionar tu proyecto
3. Functions → Logs

### Ver métricas
Functions → Dashboard → Ver estadísticas de ejecución

## Estructura de Datos Esperada

### Token FCM en Firestore
```
users/{userId}/private/fcmTokens
{
  tokens: ["token1", "token2", ...],
  updatedAt: Timestamp
}
```

### Match Document
```
matches/{matchId}
{
  users: ["userId1", "userId2"],
  lastMessage: "texto del último mensaje",
  lastMessageTime: Timestamp,
  unreadCount: {
    "userId1": 0,
    "userId2": 1
  }
}
```

### Message Document
```
matches/{matchId}/messages/{messageId}
{
  senderId: "userId",
  text: "mensaje",
  timestamp: Timestamp,
  read: false
}
```

## Troubleshooting

### Error: "Billing account not configured"
- Necesitas habilitar el Blaze Plan en Firebase Console
- Cloud Functions requiere un plan de pago

### Error: "Permission denied"
- Verifica que estés autenticado: `firebase login`
- Verifica que tengas permisos en el proyecto

### Notificaciones no llegan
1. Verifica los logs: `firebase functions:log`
2. Verifica que el usuario tenga tokens FCM guardados
3. Verifica que los tokens sean válidos
4. Revisa la configuración de FCM en el cliente

### Tokens inválidos
- La función limpia automáticamente tokens inválidos
- Los tokens se invalidan cuando:
  - El usuario desinstala la app
  - El usuario borra los datos de la app
  - El token expira (raramente)

## Costos

Cloud Functions en Blaze Plan incluye:
- **2 millones de invocaciones gratis** por mes
- **400,000 GB-segundos gratis** por mes
- **200,000 CPU-segundos gratos** por mes

Para una app de citas con tráfico moderado, probablemente te mantengas en el tier gratuito.

## Próximos Pasos

1. Desplegar las functions: `firebase deploy --only functions`
2. Probar enviando un mensaje desde la app
3. Verificar que la notificación llegue al destinatario
4. Monitorear logs para asegurar que todo funcione correctamente
