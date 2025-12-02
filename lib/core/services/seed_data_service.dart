import 'package:uuid/uuid.dart';
import '../../data/datasources/mock_users.dart';
import '../../data/models/user_model.dart';
import 'firestore_service.dart';

class SeedDataService {
  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = const Uuid();

  Future<void> seedUsers() async {
    try {
      print('🌱 Starting data seeding...');
      final mockUsers = MockUsers.getMockUsers();

      for (final user in mockUsers) {
        // Generate a real-looking UID if it's a simple mock ID
        final String uid = user.uid.startsWith('user') ? _uuid.v4() : user.uid;

        final newUser = UserModel(
          id: uid,
          uid: uid,
          name: user.name,
          age: user.age,
          bio: user.bio,
          photos: user.photos,
          location: user.location,
          distance: user.distance,
          interests: user.interests,
          gender: user.gender,
          sexualOrientation: user.sexualOrientation,
          job: user.job,
          lifestyle: user.lifestyle,
          searchIntent: user.searchIntent,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        print('🌱 Seeding user: ${newUser.name} ($uid)');
        await _firestoreService.createUser(newUser);
      }
      print('✅ Seeding completed successfully!');
    } catch (e) {
      print('❌ Error seeding data: $e');
      rethrow;
    }
  }
}
