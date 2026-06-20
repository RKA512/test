import 'package:crypto/crypto.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> fetchCurrentUser();
  
  Future<UserEntity> login({
    required String username,
    required String password,
  });

  Future<void> logout();

  Future<void> createUser({
    required String username,
    required String password,
    required String fullName,
    required String role,
  });

  Future<void> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  });

  Future<List<UserEntity>> fetchAllUsers();
}
