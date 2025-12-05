import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'presentation/providers/notification_provider.dart';

// Handler para mensajes en background (debe estar fuera de main)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('📩 Mensaje en background: ${message.notification?.title}');
}

void main() async {
  print('🚀 [MAIN] App starting...');
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  try {
    print('📦 [MAIN] Loading .env...');
    await dotenv.load(fileName: '.env');
    print('✅ [MAIN] .env loaded');
  } catch (e) {
    print('❌ [MAIN] Error loading .env: $e');
  }

  // Inicializar Firebase
  try {
    print('🔥 [MAIN] Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ [MAIN] Firebase initialized');
  } catch (e) {
    print('❌ [MAIN] Error initializing Firebase: $e');
  }

  // Configurar handler de mensajes en background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  print('🏃 [MAIN] Running app...');
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Inicializar servicio de notificaciones
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.initialize();

    // Configurar callback para navegación desde notificaciones
    notificationService.onNotificationTap = (conversationId) {
      // Navegar al chat cuando se toque una notificación
      final router = ref.read(routerProvider);
      router.go('/chat/$conversationId');
    };
  }

  @override
  Widget build(BuildContext context) {
    final appRouter = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'App Citas',
      theme: appTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
