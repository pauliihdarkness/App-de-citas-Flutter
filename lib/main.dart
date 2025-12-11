import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'presentation/providers/notification_provider.dart';

// Handler para mensajes en background (debe estar fuera de main)
// Firebase ya estará inicializado por AppBootstrap antes de que este handler se ejecute
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No intentar inicializar Firebase aquí: causará conflictos de inicialización duplicate
  // Firebase ya debe estar inicializado por el app bootstrap
  print('📩 Mensaje en background: ${message.notification?.title}');
}

// Global error notifier for on-screen display
final ValueNotifier<List<String>> _logNotifier = ValueNotifier([]);

void _log(String message) {
  // Add to beginning of list
  final list = List<String>.from(_logNotifier.value);
  list.insert(
    0,
    "${DateTime.now().toString().split(' ').last.split('.').first} $message",
  );
  if (list.length > 50) list.removeLast();
  _logNotifier.value = list;
  print(message); // Still print to console
}

void main() {
  // Capture platform errors
  PlatformDispatcher.instance.onError = (error, stack) {
    _log('❌ [PLATFORM ERROR] $error');
    return true;
  };

  FlutterError.onError = (details) {
    _log('❌ [FLUTTER ERROR] ${details.exception}');
    FlutterError.presentError(details);
  };

  _log('🚀 [MAIN] App starting...');
  WidgetsFlutterBinding.ensureInitialized();

  // Register background handler
  try {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    _log('⚠️ [MAIN] Failed to register background handler: $e');
  }

  _log('🏃 [MAIN] Running app bootstrap...');
  runApp(const AppBootstrap());
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  bool _isInitialized = false;
  String? _error;
  static bool _initInProgress = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Prevent duplicate initialization attempts
    if (_initInProgress) {
      _log('ℹ️ [BOOTSTRAP] Initialization already in progress...');
      return;
    }
    _initInProgress = true;

    try {
      // Only load .env for non-web platforms
      // On web, Netlify provides env vars directly
      if (!kIsWeb) {
        _log('📦 [BOOTSTRAP] Loading .env...');
        try {
          await dotenv.load(fileName: '.env');
          _log('✅ [BOOTSTRAP] .env loaded successfully');
        } catch (envError) {
          _log('⚠️ [BOOTSTRAP] .env not found or error loading: $envError');
          _log('ℹ️ [BOOTSTRAP] Continuing without .env (using defaults)');
          // Don't fail the whole app if .env is missing
        }
      } else {
        _log('ℹ️ [BOOTSTRAP] Running on web, skipping .env file (using Netlify env vars)');
      }

      _log('🔥 [BOOTSTRAP] Initializing Firebase...');
      try {
        if (Firebase.apps.isEmpty) {
          _log('🔥 [BOOTSTRAP] Firebase apps list is empty, initializing...');
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
          _log('✅ [BOOTSTRAP] Firebase initialized successfully');
        } else {
          _log(
            'ℹ️ [BOOTSTRAP] Firebase already initialized (${Firebase.apps.length} apps)',
          );
        }
      } catch (firebaseError) {
        _log('🔍 [BOOTSTRAP] Firebase error details: $firebaseError');
        // Handle specific Firebase errors
        if (firebaseError.toString().contains('duplicate-app') ||
            firebaseError.toString().contains('already exists')) {
          _log(
            'ℹ️ [BOOTSTRAP] Firebase app already initialized (duplicate attempt caught)',
          );
          // Don't throw, continue anyway since Firebase is already initialized
        } else {
          _log('❌ [BOOTSTRAP] Firebase initialization failed: $firebaseError');
          rethrow;
        }
      }

      _log('✅ [BOOTSTRAP] Initialization completed successfully');
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e, stack) {
      _log('❌ [BOOTSTRAP] Init Error: $e');
      _log('Stack: $stack');
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      _initInProgress = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show errors or logs if not initialized
    if (!_isInitialized || _error != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF1A1A1A),
          body: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_error != null) ...[
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Error al iniciar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            setState(() {
                              _error = null;
                              _initialize();
                            });
                          },
                          label: const Text('Reintentar'),
                        ),
                      ] else ...[
                        const CircularProgressIndicator(
                          color: Color(0xFFE31B5D),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Iniciando...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // On-screen console overlay removed
              /*
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 200,
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: ValueListenableBuilder<List<String>>(
                    valueListenable: _logNotifier,
                    builder: (context, logs, child) {
                      return ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: logs.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: Colors.white10),
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          Color color = Colors.white70;
                          if (log.contains('❌')) color = Colors.redAccent;
                          if (log.contains('⚠️')) color = Colors.orangeAccent;
                          if (log.contains('✅')) color = Colors.greenAccent;

                          return Text(
                            log,
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontFamily: 'Courier',
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              */
            ],
          ),
        ),
      );
    }

    return const ProviderScope(child: MyApp());
  }
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
    // Initialize notifications asynchronously without blocking the UI
    _initializeNotificationsAsync();
  }

  Future<void> _initializeNotificationsAsync() async {
    // Run in background without blocking the app initialization
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        if (!mounted) return;
        final notificationService = ref.read(notificationServiceProvider);
        await notificationService.initialize();

        if (mounted) {
          notificationService.onNotificationTap = (conversationId) {
            final router = ref.read(routerProvider);
            router.go('/chat/$conversationId');
          };
        }
      } catch (e) {
        print('❌ [MyApp] Error initializing notifications: $e');
      }
    });
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
