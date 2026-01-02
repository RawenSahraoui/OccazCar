import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream pour écouter les changements d'état de l'utilisateur
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Inscription avec email et mot de passe
  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required UserType userType,
    String? phoneNumber,
  }) async {
    try {
      // Créer l'utilisateur dans Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) return null;

      // Mettre à jour le profil
      await user.updateDisplayName(displayName);

      // Créer le modèle utilisateur
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        phoneNumber: phoneNumber,
        userType: userType,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isActive: true,
      );

      // Sauvegarder dans Firestore
      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }

  // Connexion avec email et mot de passe
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) return null;

      // Mettre à jour la dernière connexion
      await _firestore.collection('users').doc(user.uid).update({
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
      });

      // Récupérer les données utilisateur
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return null;

      return UserModel.fromMap(userDoc.data()!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erreur lors de la connexion: $e');
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }

  // Récupérer les données de l'utilisateur actuel
  Future<UserModel?> getCurrentUserData() async {
    try {
      final User? user = currentUser;
      if (user == null) return null;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return null;

      return UserModel.fromMap(userDoc.data()!);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des données: $e');
    }
  }

  // Mettre à jour le profil utilisateur
  Future<void> updateUserProfile({
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    UserType? userType,
  }) async {
    try {
      final User? user = currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      final Map<String, dynamic> updates = {};

      if (displayName != null) {
        await user.updateDisplayName(displayName);
        updates['displayName'] = displayName;
      }

      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
        updates['photoUrl'] = photoUrl;
      }

      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (userType != null) updates['userType'] = userType.name;

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(updates);
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil: $e');
    }
  }

  // Réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erreur lors de la réinitialisation: $e');
    }
  }

  // Changer le mot de passe
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final User? user = currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      // Réauthentifier l'utilisateur
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Changer le mot de passe
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erreur lors du changement de mot de passe: $e');
    }
  }

  // Supprimer le compte
  Future<void> deleteAccount(String password) async {
    try {
      final User? user = currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      // Réauthentifier l'utilisateur
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Supprimer les données Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Supprimer le compte
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du compte: $e');
    }
  }

  // Gestion des erreurs Firebase Auth
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Le mot de passe est trop faible (min. 6 caractères)';
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet email';
      case 'invalid-email':
        return 'L\'adresse email est invalide';
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard';
      case 'operation-not-allowed':
        return 'Opération non autorisée';
      case 'requires-recent-login':
        return 'Veuillez vous reconnecter pour effectuer cette action';
      default:
        return 'Erreur d\'authentification: ${e.message}';
    }
  }
}