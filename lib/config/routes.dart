import 'package:app_citas/presentation/screens/profile/profile_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/auth/complete_profile_screen.dart';
import '../presentation/screens/main/main_scaffold.dart';
import '../presentation/screens/profile/edit_profile_screen.dart';
import '../presentation/screens/profile/user_detail_screen.dart';
import '../presentation/screens/chat/chat_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/notifications/notification_center_screen.dart';
import '../presentation/providers/auth_provider.dart';

/// Configuración de rutas de la aplicación
/// Configuración de rutas de la aplicación
final routerProvider = Provider<GoRouter>((ref) {
  // final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(
      ref.watch(userProfileProvider.stream),
    ),
    redirect: (context, state) {
      final authStateValue = ref.read(authStateProvider);
      final userProfileState = ref.read(userProfileProvider);

      print('🔄 [ROUTER] Location: ${state.matchedLocation}');
      print(
        '👤 [ROUTER] Auth Loading: ${authStateValue.isLoading}, Has Value: ${authStateValue.hasValue}, Value: ${authStateValue.value?.uid}',
      );
      print(
        '📄 [ROUTER] Profile Loading: ${userProfileState.isLoading}, Has Value: ${userProfileState.hasValue}, Active: ${userProfileState.value?.active}',
      );

      // Si estamos cargando autenticación o perfil, mostrar splash
      try {
        if (authStateValue.isLoading || userProfileState.isLoading) {
          print('⏳ [ROUTER] Still loading... showing splash');
          return '/splash';
        }
      } catch (e, st) {
        print('❌ [ROUTER] Error during loading check: $e');
        print(st);
        // Si hay un error al evaluar el estado, evitar bloquear la navegación
        return null;
      }

      final isLoggedIn = authStateValue.value != null;
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';
      final isSplash = state.matchedLocation == '/splash';
      final isCompletingProfile = state.matchedLocation == '/complete-profile';

      if (!isLoggedIn) {
        // Allow access only to login/register while unauthenticated.
        // Do NOT keep the user on /splash once loading finished.
        if (isLoggingIn || isRegistering) return null;
        print('🚫 [ROUTER] Not logged in, redirecting to login');
        return '/login';
      }

      // Si está logueado, verificar si el perfil está completo
      final userProfile = userProfileState.value;

      // Si no hay perfil cargado aún (pero no está loading), esperar
      if (userProfile == null) {
        print('⚠️ [ROUTER] Logged in but profile is null');
        return null;
      }

      // `active` puede ser null; tratar sólo true como perfil completo
      final isProfileComplete = (userProfile.active == true);

      if (!isProfileComplete) {
        if (isCompletingProfile) return null;
        print(
          '📝 [ROUTER] Profile incomplete (active=${userProfile.active}), redirecting to complete-profile',
        );
        return '/complete-profile';
      }

      if (isLoggingIn || isRegistering || isCompletingProfile || isSplash) {
        print('✅ [ROUTER] All good, redirecting to home');
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/complete-profile',
        name: 'completeProfile',
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainScaffold(),
      ),

      GoRoute(
        path: '/chat/:conversationId',
        name: 'chat',
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId']!;
          return ChatScreen(conversationId: conversationId);
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'editProfile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/user/:userId',
        name: 'userDetail',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final hideActions =
              state.uri.queryParameters['hideActions'] == 'true';
          return UserDetailScreen(userId: userId, hideActions: hideActions);
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationCenterScreen(),
      ),
    ],
  );
});

/// Clase para convertir Stream a Listenable para GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Placeholder screens
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
