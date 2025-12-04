import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../data/models/user_model.dart';
import '../services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: dotenv.env['GOOGLE_SIGN_IN_CLIENT_ID'],
  );
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
            bio: '¡Hola! Soy nueva aquí.',
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

  // Actualizar Email
  Future<void> updateEmail(String newEmail, String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');

      // Re-autenticar para operaciones sensibles
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      await user.verifyBeforeUpdateEmail(newEmail);
    } catch (e) {
      print('Error al actualizar email: $e');
      rethrow;
    }
  }

  // Actualizar Contraseña
  Future<void> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');

      // Re-autenticar
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);
    } catch (e) {
      print('Error al actualizar contraseña: $e');
      rethrow;
    }
  }

  // Eliminar Cuenta
  Future<void> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');

      // Re-autenticar
      // Nota: Si el usuario usó Google, esto fallará si solo pedimos password.
      // Para simplificar, asumimos email/password por ahora o requerimos re-login reciente.
      // Una mejor implementación manejaría ambos proveedores.

      // Intentar reautenticar con email/password si tiene provider de password
      if (user.providerData.any((p) => p.providerId == 'password')) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      } else {
        // Si es Google, forzar re-login (o manejar reauth con Google)
        // Por ahora lanzamos error si no es password provider
        // throw Exception('Por favor cierra sesión y vuelve a entrar con Google para eliminar tu cuenta.');
        // O simplemente procedemos si el login es reciente (menos de 5 min)
      }

      // Eliminar datos de Firestore
      await _firestoreService.deleteUser(
        user.uid,
      ); // Necesitamos implementar esto en FirestoreService

      // Eliminar usuario de Auth
      await user.delete();
    } catch (e) {
      print('Error al eliminar cuenta: $e');
      rethrow;
    }
  }
}
