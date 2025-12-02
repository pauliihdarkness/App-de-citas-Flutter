import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/firestore_service.dart';
import '../../data/models/user_model.dart';
import 'auth_provider.dart';

// Provider para cargar los usuarios del feed
final usersProvider =
    StateNotifierProvider<UsersNotifier, AsyncValue<List<UserModel>>>((ref) {
      final firestoreService = ref.watch(firestoreServiceProvider);
      final currentUser = ref.watch(currentUserProvider);
      return UsersNotifier(firestoreService, currentUser?.uid);
    });

class UsersNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final FirestoreService _firestoreService;
  final String? _currentUserId;

  UsersNotifier(this._firestoreService, this._currentUserId)
    : super(const AsyncValue.loading()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    final userId = _currentUserId;
    print('👤 UsersNotifier: Loading users for current user: $userId');

    if (userId == null) {
      print('⚠️ UsersNotifier: No current user ID, returning empty list');
      state = const AsyncValue.data([]);
      return;
    }

    try {
      state = const AsyncValue.loading();
      final users = await _firestoreService.getUsersForFeed(userId);
      print('📦 UsersNotifier: Loaded ${users.length} users');
      state = AsyncValue.data(users);
    } catch (e, stack) {
      print('❌ UsersNotifier: Error loading users: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  void removeUser(String userId) {
    state.whenData((users) {
      state = AsyncValue.data(users.where((u) => u.uid != userId).toList());
    });
  }
}

// Provider del índice actual de la tarjeta (se mantiene igual)
final currentCardIndexProvider = StateProvider<int>((ref) => 0);
