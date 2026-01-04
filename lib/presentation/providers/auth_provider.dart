import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});


final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);


  if (authState.value == null) {
    return null;
  }

  final repository = ref.watch(authRepositoryProvider);
  final result = await repository.getCurrentUserData();
  return result.isSuccess ? result.data : null;
});

final signUpProvider = StateNotifierProvider<SignUpNotifier, AsyncValue<void>>((ref) {
  return SignUpNotifier(ref.watch(authRepositoryProvider));
});

class SignUpNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;

  SignUpNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserType userType,
    String? phoneNumber,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repository.signUp(
      email: email,
      password: password,
      displayName: displayName,
      userType: userType,
      phoneNumber: phoneNumber,
    );

    if (result.isSuccess) {
      state = const AsyncValue.data(null);
      return true;
    } else {
      state = AsyncValue.error(result.error!, StackTrace.current);
      return false;
    }
  }
}

final signInProvider = StateNotifierProvider<SignInNotifier, AsyncValue<void>>((ref) {
  return SignInNotifier(ref.watch(authRepositoryProvider));
});

class SignInNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;

  SignInNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repository.signIn(
      email: email,
      password: password,
    );

    if (result.isSuccess) {
      state = const AsyncValue.data(null);
      return true;
    } else {
      state = AsyncValue.error(result.error!, StackTrace.current);
      return false;
    }
  }
}

final signOutProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final repository = ref.read(authRepositoryProvider);
    await repository.signOut();
  };
});

final resetPasswordProvider = StateNotifierProvider<ResetPasswordNotifier, AsyncValue<void>>((ref) {
  return ResetPasswordNotifier(ref.watch(authRepositoryProvider));
});

class ResetPasswordNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;

  ResetPasswordNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> resetPassword(String email) async {
    state = const AsyncValue.loading();

    final result = await _repository.resetPassword(email);

    if (result.isSuccess) {
      state = const AsyncValue.data(null);
      return true;
    } else {
      state = AsyncValue.error(result.error!, StackTrace.current);
      return false;
    }
  }
}

final updateProfileProvider = StateNotifierProvider<UpdateProfileNotifier, AsyncValue<void>>((ref) {
  return UpdateProfileNotifier(ref.watch(authRepositoryProvider));
});

class UpdateProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;

  UpdateProfileNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> updateProfile({
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    UserType? userType,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repository.updateProfile(
      displayName: displayName,
      phoneNumber: phoneNumber,
      photoUrl: photoUrl,
      userType: userType,
    );

    if (result.isSuccess) {
      state = const AsyncValue.data(null);
      return true;
    } else {
      state = AsyncValue.error(result.error!, StackTrace.current);
      return false;
    }
  }
}