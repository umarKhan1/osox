import 'package:osox/features/auth/domain/models/user_model.dart';

abstract class IAuthRepository {
  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  Future<UserModel> signIn({required String email, required String password});

  Future<UserModel?> getCurrentUser();
  Future<void> signOut();
}
