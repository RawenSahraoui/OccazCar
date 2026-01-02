import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  // Stream de l'état d'authentification
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  // Utilisateur actuel
  User? get currentUser => _authService.currentUser;

  // Inscription
  Future<Result<UserModel>> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserType userType,
    String? phoneNumber,
  }) async {
    try {
      final user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
        userType: userType,
        phoneNumber: phoneNumber,
      );

      if (user == null) {
        return Result.error('Erreur lors de la création du compte');
      }

      return Result.success(user);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  // Connexion
  Future<Result<UserModel>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (user == null) {
        return Result.error('Erreur lors de la connexion');
      }

      return Result.success(user);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  // Déconnexion
  Future<Result<void>> signOut() async {
    try {
      await _authService.signOut();
      return Result.success(null);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  // Récupérer les données utilisateur
  Future<Result<UserModel>> getCurrentUserData() async {
    try {
      final user = await _authService.getCurrentUserData();
      
      if (user == null) {
        return Result.error('Utilisateur non trouvé');
      }

      return Result.success(user);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  // Mettre à jour le profil
  Future<Result<void>> updateProfile({
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    UserType? userType,
  }) async {
    try {
      await _authService.updateUserProfile(
        displayName: displayName,
        phoneNumber: phoneNumber,
        photoUrl: photoUrl,
        userType: userType,
      );
      return Result.success(null);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  // Réinitialiser le mot de passe
  Future<Result<void>> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      return Result.success(null);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  // Changer le mot de passe
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return Result.success(null);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  // Supprimer le compte
  Future<Result<void>> deleteAccount(String password) async {
    try {
      await _authService.deleteAccount(password);
      return Result.success(null);
    } catch (e) {
      return Result.error(e.toString());
    }
  }
}

// Classe Result pour gérer les succès et erreurs
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  Result._({this.data, this.error, required this.isSuccess});

  factory Result.success(T data) {
    return Result._(data: data, isSuccess: true);
  }

  factory Result.error(String error) {
    return Result._(error: error, isSuccess: false);
  }
}