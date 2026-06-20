import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DatabaseHelper _dbHelper;
  UserModel? _currentUser;

  AuthRepositoryImpl({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  @override
  Future<UserModel?> fetchCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );

      if (results.isEmpty) {
        throw const AuthenticationFailure('خطأ: اسم المستخدم غير موجود بالنظام.');
      }

      final userRow = results.first;
      final hashedInput = _hashPassword(password);
      final storedHash = userRow['password_hash'] as String;

      if (hashedInput != storedHash) {
        throw const AuthenticationFailure('خطأ: كلمة المرور المدخلة غير صحيحة.');
      }

      final userModel = UserModel.fromMap(userRow);
      _currentUser = userModel;

      // Log action in Audit Logger
      await _dbHelper.insertAuditLog(
        userId: userModel.id,
        action: 'تسجيل دخول ناجح',
        entityType: 'users',
        entityId: userModel.id,
      );

      return userModel;
    } on AuthenticationFailure {
      rethrow;
    } catch (e) {
      throw DatabaseFailure('فشلت عملية التحقق في لقاعدة البيانات: $e');
    }
  }

  @override
  Future<void> logout() async {
    if (_currentUser != null) {
      await _dbHelper.insertAuditLog(
        userId: _currentUser!.id,
        action: 'تسجيل خروج',
        entityType: 'users',
        entityId: _currentUser!.id,
      );
    }
    _currentUser = null;
  }

  @override
  Future<void> createUser({
    required String username,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final db = await _dbHelper.database;
      
      // Check if user already exists
      final duplicateCheck = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );

      if (duplicateCheck.isNotEmpty) {
        throw const DuplicateUserFailure('اسم المستخدم هذا مسجل مسبقاً لموظف آخر.');
      }

      final newUser = UserModel(
        username: username,
        fullName: fullName,
        role: role,
        createdAt: DateTime.now(),
      );

      final map = newUser.toMap();
      map['password_hash'] = _hashPassword(password);

      final insertedId = await db.insert('users', map);

      await _dbHelper.insertAuditLog(
        userId: _currentUser?.id,
        action: 'إنشاء حساب جديد: $username',
        entityType: 'users',
        entityId: insertedId,
      );
    } catch (e) {
      if (e is DuplicateUserFailure) rethrow;
      throw DatabaseFailure('فشل إنشاء حساب الموظف في قاعدة البيانات: $e');
    }
  }

  @override
  Future<void> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (results.isEmpty) {
        throw const AuthenticationFailure('المستخدم غير متوفر.');
      }

      final userRow = results.first;
      final storedHash = userRow['password_hash'] as String;
      final inputCurrentHash = _hashPassword(currentPassword);

      if (inputCurrentHash != storedHash) {
        throw const AuthenticationFailure('كلمة المرور الحالية خاطئة.');
      }

      final newHash = _hashPassword(newPassword);
      await db.update(
        'users',
        {'password_hash': newHash},
        where: 'id = ?',
        whereArgs: [userId],
      );

      await _dbHelper.insertAuditLog(
        userId: userId,
        action: 'تغيير كلمة المرور',
        entityType: 'users',
        entityId: userId,
      );
    } catch (e) {
      if (e is AuthenticationFailure) rethrow;
      throw DatabaseFailure('فشل تحديث كلمة المرور في قاعدة البيانات: $e');
    }
  }

  @override
  Future<List<UserModel>> fetchAllUsers() async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query('users', orderBy: 'id ASC');
      return results.map((row) => UserModel.fromMap(row)).toList();
    } catch (e) {
      throw DatabaseFailure('فشل استيراد الموظفين من قاعدة البيانات: $e');
    }
  }
}
