import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    super.id,
    required super.username,
    required super.fullName,
    required super.role,
    required super.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      fullName: map['full_name'] as String,
      role: map['role'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'full_name': fullName,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
