import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/models/user_model.dart';
import '../services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  // Stream de estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // Sign in con Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger el flujo de autenticación de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // El usuario canceló el sign-in
        return null;
      }

      // Obtener los detalles de autenticación
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Crear credencial para Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in a Firebase con la credencial de Google
      final userCredential = await _auth.signInWithCredential(credential);

      // Verificar si existe el perfil en Firestore
      if (userCredential.user != null) {
        final user = userCredential.user!;
        final existingProfile = await _firestoreService.getUser(user.uid);

        if (existingProfile == null) {
          // Crear nuevo perfil
          final newProfile = UserModel(
            id: user.uid,
            uid: user.uid,
            name: user.displayName ?? 'Usuario',
            age: 18, // Edad por defecto, el usuario debe actualizarla
            bio: '¡Hola! Soy nuevo aquí.',
            photos: [if (user.photoURL != null) user.photoURL!],
            location: UserLocation(country: '', state: '', city: ''),
            gender: 'Prefiero no decir',
            sexualOrientation: 'Prefiero no decir',
            job: UserJob(title: '', company: '', education: ''),
            lifestyle: UserLifestyle(
              drink: '',
              smoke: '',
              workout: '',
              zodiac: '',
              height: '',
            ),
            searchIntent: 'No lo sé aún',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await _firestoreService.createUser(newProfile);
        }
      }

      return userCredential;
    } catch (e) {
      print('Error en Google Sign-In: $e');
      rethrow;
    }
  }

  // Sign in con email y contraseña
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verificar si existe el perfil en Firestore (por seguridad)
      if (userCredential.user != null) {
        final user = userCredential.user!;
        final existingProfile = await _firestoreService.getUser(user.uid);

        if (existingProfile == null) {
          // Crear nuevo perfil si no existe
          final newProfile = UserModel(
            id: user.uid,
            uid: user.uid,
            name: email.split('@')[0],
            age: 18,
            bio: '¡Hola! Soy nuevo aquí.',
            photos: [],
            location: UserLocation(country: '', state: '', city: ''),
            gender: 'Prefiero no decir',
            sexualOrientation: 'Prefiero no decir',
            job: UserJob(title: '', company: '', education: ''),
            lifestyle: UserLifestyle(
              drink: '',
              smoke: '',
              workout: '',
              zodiac: '',
              height: '',
            ),
            searchIntent: 'No lo sé aún',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await _firestoreService.createUser(newProfile);
        }
      }

      return userCredential;
    } catch (e) {
      print('Error en sign in: $e');
      rethrow;
    }
  }

  // Registro con email y contraseña
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Crear perfil de usuario en Firestore
      if (userCredential.user != null) {
        final user = userCredential.user!;
        final newProfile = UserModel(
          id: user.uid,
          uid: user.uid,
          name: email.split(
            '@',
          )[0], // Usar parte del email como nombre temporal
          age: 18,
          bio: '¡Hola! Soy nuevo aquí.',
          photos: [],
          location: UserLocation(country: '', state: '', city: ''),
          gender: 'Prefiero no decir',
          sexualOrientation: 'Prefiero no decir',
          job: UserJob(title: '', company: '', education: ''),
          lifestyle: UserLifestyle(
            drink: '',
            smoke: '',
            workout: '',
            zodiac: '',
            height: '',
          ),
          searchIntent: 'No lo sé aún',
          active: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestoreService.createUser(newProfile);
      }

      return userCredential;
    } catch (e) {
      print('Error en registro: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      print('Error en sign out: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error al enviar email de recuperación: $e');
      rethrow;
    }
  }
}
