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
      final data = user.toJson();
      // Si es creación, aseguramos createdAt y updatedAt
      if (data['createdAt'] == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _usersCollection.doc(user.uid).set(data, SetOptions(merge: true));
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
      final data = user.toJson();
      data['updatedAt'] =
          FieldValue.serverTimestamp(); // Forzar timestamp del servidor
      await _usersCollection.doc(user.uid).update(data);
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
      // También actualizamos el updatedAt del documento principal para reflejar actividad
      await _usersCollection.doc(uid).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });

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
  // Excluye usuarios que ya han sido evaluados (like o pass)
  Future<List<UserModel>> getUsersForFeed(String currentUserId) async {
    try {
      print('🔍 Fetching users for feed (excluding $currentUserId)...');

      // 1. Obtener todos los usuarios que ya fueron evaluados (like o pass)
      final likesSnapshot = await _likesCollection
          .where('fromUserId', isEqualTo: currentUserId)
          .get();

      final evaluatedUserIds = likesSnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            return data?['toUserId'] as String?;
          })
          .whereType<String>()
          .toSet();

      print('📊 User has evaluated ${evaluatedUserIds.length} profiles');

      // 2. Obtener usuarios potenciales (excluyendo el usuario actual)
      final snapshot = await _usersCollection
          .where('uid', isNotEqualTo: currentUserId)
          .limit(50) // Aumentamos el límite para compensar el filtrado
          .get();

      print('✅ Found ${snapshot.docs.length} potential users in Firestore');

      // 3. Filtrar usuarios ya evaluados
      final users = snapshot.docs
          .map((doc) {
            try {
              return UserModel.fromJson(doc.data() as Map<String, dynamic>);
            } catch (e) {
              print('❌ Error parsing user ${doc.id}: $e');
              return null;
            }
          })
          .whereType<UserModel>()
          .where((user) => !evaluatedUserIds.contains(user.uid))
          .take(20) // Limitar a 20 usuarios finales
          .toList();

      print('✨ Returning ${users.length} new users for feed');
      return users;
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
        final matchId = '${users[0]}_${users[1]}';

        await _matchesCollection.doc(matchId).set({
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

  // --- GESTIÓN DE FOTOS ---

  // Agregar una foto al array de fotos del usuario
  Future<void> addUserPhoto(String userId, String photoUrl) async {
    try {
      await _usersCollection.doc(userId).update({
        'photos': FieldValue.arrayUnion([photoUrl]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding user photo: $e');
      rethrow;
    }
  }

  // Eliminar una foto del array de fotos del usuario
  Future<void> removeUserPhoto(String userId, String photoUrl) async {
    try {
      await _usersCollection.doc(userId).update({
        'photos': FieldValue.arrayRemove([photoUrl]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error removing user photo: $e');
      rethrow;
    }
  }

  // Actualizar el orden o la lista completa de fotos
  Future<void> updateUserPhotos(String userId, List<String> photoUrls) async {
    try {
      if (photoUrls.length > 9) {
        throw Exception('Maximum 9 photos allowed');
      }
      await _usersCollection.doc(userId).update({
        'photos': photoUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user photos: $e');
      rethrow;
    }
  }

  // Verificar si el usuario puede agregar más fotos
  Future<bool> canAddMorePhotos(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      final photos = List<String>.from(data['photos'] ?? []);

      return photos.length < 9;
    } catch (e) {
      print('Error checking photo limit: $e');
      return false;
    }
  }

  // Eliminar usuario
  Future<void> deleteUser(String uid) async {
    try {
      // Eliminar likes dados
      final likesGiven = await _likesCollection
          .where('fromUserId', isEqualTo: uid)
          .get();
      for (var doc in likesGiven.docs) {
        await doc.reference.delete();
      }

      // Eliminar likes recibidos
      final likesReceived = await _likesCollection
          .where('toUserId', isEqualTo: uid)
          .get();
      for (var doc in likesReceived.docs) {
        await doc.reference.delete();
      }

      // Eliminar matches (opcional, o marcar como deleted)
      // Esto requeriría buscar en arrays, lo cual es costoso.
      // Por ahora solo eliminamos el perfil.

      // Eliminar documento de usuario
      await _usersCollection.doc(uid).delete();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }
}
