import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Colecciones
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _likesCollection => _firestore.collection('likes');
  CollectionReference get _matchesCollection =>
      _firestore.collection('matches');

  // Obtener usuario por UID
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Stream de usuario por UID
  Stream<UserModel?> getUserStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Crear o actualizar usuario
  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(user.toJson());
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  // Crear documento privado con datos sensibles (una sola vez)
  Future<void> setPrivateData(String uid, Map<String, dynamic> data) async {
    try {
      await _usersCollection
          .doc(uid)
          .collection('private')
          .doc('data')
          .set(data);
    } catch (e) {
      print('Error setting private data: $e');
      rethrow;
    }
  }

  // Actualizar perfil de usuario
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).update(user.toJson());
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Actualizar datos privados del usuario
  Future<void> updateUserPrivateData(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      await _usersCollection
          .doc(uid)
          .collection('private')
          .doc('data')
          .set(data, SetOptions(merge: true));
    } catch (e) {
      print('Error updating private data: $e');
      rethrow;
    }
  }

  // Obtener usuarios para el feed
  // TODO: Implementar filtros de geolocalización y preferencias
  Future<List<UserModel>> getUsersForFeed(String currentUserId) async {
    try {
      print('🔍 Fetching users for feed (excluding $currentUserId)...');
      // Por ahora traemos todos los usuarios excepto el actual
      // En producción esto debe ser mucho más optimizado usando índices
      final snapshot = await _usersCollection
          .where('uid', isNotEqualTo: currentUserId)
          .limit(20)
          .get();

      print('✅ Found ${snapshot.docs.length} users in Firestore');

      return snapshot.docs
          .map((doc) {
            try {
              print('📄 Parsing user doc: ${doc.id}');
              return UserModel.fromJson(doc.data() as Map<String, dynamic>);
            } catch (e) {
              print('❌ Error parsing user ${doc.id}: $e');
              return null;
            }
          })
          .whereType<UserModel>() // Filter out nulls
          .toList();
    } catch (e) {
      print('❌ Error getting feed users: $e');
      return [];
    }
  }

  // Registrar Like/Pass
  Future<bool> recordLike(
    String fromUserId,
    String toUserId,
    String type,
  ) async {
    try {
      await _likesCollection.add({
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'type': type, // 'like' or 'pass'
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (type == 'like') {
        return await _checkForMatch(fromUserId, toUserId);
      }
      return false;
    } catch (e) {
      print('Error recording like: $e');
      return false;
    }
  }

  // Verificar si hay Match
  Future<bool> _checkForMatch(String fromUserId, String toUserId) async {
    try {
      // Buscar si el otro usuario ya dio like
      final snapshot = await _likesCollection
          .where('fromUserId', isEqualTo: toUserId)
          .where('toUserId', isEqualTo: fromUserId)
          .where('type', isEqualTo: 'like')
          .get();

      if (snapshot.docs.isNotEmpty) {
        // ¡Es un Match!
        print('MATCH FOUND!');

        // Crear documento de Match
        final users = [fromUserId, toUserId]..sort(); // Ordenar alfabéticamente
        await _matchesCollection.add({
          'users': users,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': null,
          'lastMessageTime': null,
        });

        // TODO: Enviar notificación push
        return true;
      }
      return false;
    } catch (e) {
      print('Error checking match: $e');
      return false;
    }
  }
}
