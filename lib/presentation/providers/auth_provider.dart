import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../data/models/user_model.dart';

// Provider del servicio de autenticación
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provider del stream de estado de autenticación
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Provider del usuario actual
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
});

// Provider del perfil de usuario en Firestore
final userProfileProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  // We need firestoreServiceProvider. If it's in users_provider, we import it.
  // Or we define it here and remove from users_provider.
  // Let's assume we keep it in users_provider for now to avoid breaking other things,
  // but circular dependency might be an issue.
  // BETTER: Define it here (core service) and remove from users_provider.
  final firestoreService = ref.watch(firestoreServiceProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return firestoreService.getUserStream(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// Provider del servicio de Firestore
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
