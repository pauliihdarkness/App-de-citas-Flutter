# Uso del Sistema de Notificaciones

Este documento explica cómo usar el sistema de notificaciones implementado en la aplicación.

## Componentes Principales

### 1. NotificationService
Servicio que maneja Firebase Cloud Messaging y notificaciones locales.

### 2. NotificationProvider
Providers de Riverpod para acceder a contadores de mensajes no leídos.

### 3. NotificationBadge
Widget reutilizable para mostrar badges de notificaciones.

---

## Ejemplo de Uso en Pantallas

### En la Lista de Conversaciones

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_badge.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener contador total de mensajes no leídos
    final totalUnread = ref.watch(totalUnreadMessagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensajes'),
        actions: [
          // Mostrar badge en el ícono
          totalUnread.when(
            data: (count) => NotificationBadge(
              count: count,
              child: IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  // Acción al tocar notificaciones
                },
              ),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final conversationId = 'conversation_id_here';
          
          // Obtener contador de no leídos para esta conversación
          final unreadCount = ref.watch(
            conversationUnreadCountProvider(conversationId),
          );

          return unreadCount.when(
            data: (count) => ListTile(
              leading: NotificationBadge(
                count: count,
                child: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
              ),
              title: const Text('Nombre del usuario'),
              subtitle: const Text('Último mensaje...'),
              onTap: () {
                // Navegar al chat
                Navigator.pushNamed(
                  context,
                  '/chat',
                  arguments: conversationId,
                );
              },
            ),
            loading: () => const ListTile(
              title: Text('Cargando...'),
            ),
            error: (_, __) => const SizedBox(),
          );
        },
      ),
    );
  }
}
```

### En el Bottom Navigation

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_badge.dart';

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalUnread = ref.watch(totalUnreadMessagesProvider);

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: totalUnread.when(
              data: (count) => NotificationBadge(
                count: count,
                child: const Icon(Icons.chat),
              ),
              loading: () => const Icon(Icons.chat),
              error: (_, __) => const Icon(Icons.chat),
            ),
            label: 'Mensajes',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
```

### En la Pantalla de Chat

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  
  const ChatScreen({
    super.key,
    required this.conversationId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ChatService _chatService = ChatService();
  
  @override
  void initState() {
    super.initState();
    // Marcar mensajes como leídos al abrir el chat
    _markMessagesAsRead();
  }

  Future<void> _markMessagesAsRead() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await _chatService.markAsRead(widget.conversationId, userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: StreamBuilder(
              stream: _chatService.getMessages(widget.conversationId),
              builder: (context, snapshot) {
                // Construir lista de mensajes
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    final message = snapshot.data![index];
                    return ListTile(
                      title: Text(message.text),
                    );
                  },
                );
              },
            ),
          ),
          // Input de mensaje
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final userId = FirebaseAuth.instance.currentUser?.uid;
                    if (userId != null) {
                      await _chatService.sendMessage(
                        conversationId: widget.conversationId,
                        senderId: userId,
                        text: 'Mensaje de prueba',
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Providers Disponibles

### `notificationServiceProvider`
Proporciona acceso al servicio de notificaciones.

```dart
final notificationService = ref.read(notificationServiceProvider);
await notificationService.initialize();
```

### `totalUnreadMessagesProvider`
Stream del contador total de mensajes no leídos.

```dart
final totalUnread = ref.watch(totalUnreadMessagesProvider);
totalUnread.when(
  data: (count) => Text('$count mensajes no leídos'),
  loading: () => CircularProgressIndicator(),
  error: (_, __) => Text('Error'),
);
```

### `conversationUnreadCountProvider`
Stream del contador de mensajes no leídos por conversación.

```dart
final unreadCount = ref.watch(
  conversationUnreadCountProvider('conversation_id'),
);
```

### `hasUnreadNotificationsProvider`
Stream booleano que indica si hay notificaciones no leídas.

```dart
final hasUnread = ref.watch(hasUnreadNotificationsProvider);
hasUnread.when(
  data: (hasUnread) => hasUnread ? Icon(Icons.circle) : SizedBox(),
  loading: () => SizedBox(),
  error: (_, __) => SizedBox(),
);
```

---

## Personalización del Badge

El widget `NotificationBadge` acepta varios parámetros:

```dart
NotificationBadge(
  count: 5,
  backgroundColor: Colors.red,  // Color de fondo del badge
  textColor: Colors.white,      // Color del texto
  size: 6,                      // Tamaño del badge (afecta padding y fuente)
  child: Icon(Icons.chat),      // Widget hijo
)
```

---

## Flujo de Notificaciones

1. **Usuario A envía mensaje a Usuario B**
   - Se llama a `ChatService.sendMessage()`
   - Se incrementa `unreadCount[userId_B]` en Firestore
   - Se actualiza `lastMessage` y `lastMessageTime`

2. **Usuario B ve el badge actualizado**
   - El `conversationUnreadCountProvider` escucha cambios en Firestore
   - El badge se actualiza automáticamente con el nuevo contador

3. **Usuario B abre el chat**
   - Se llama a `ChatService.markAsRead()`
   - Se resetea `unreadCount[userId_B]` a 0
   - Se marcan los mensajes individuales como leídos
   - El badge desaparece automáticamente

---

## Notas Importantes

- Los contadores se actualizan en tiempo real gracias a los Streams de Firestore
- El badge solo se muestra cuando `count > 0`
- Los mensajes se marcan como leídos automáticamente al abrir el chat
- El servicio de notificaciones se inicializa al arrancar la app en `main.dart`
