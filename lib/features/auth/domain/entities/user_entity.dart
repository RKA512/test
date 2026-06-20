class UserEntity {
  final int? id;
  final String username;
  final String fullName;
  final String role; // 'admin' | 'receptionist'
  final DateTime createdAt;

  const UserEntity({
    this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isReceptionist => role == 'receptionist';
  String get roleArabic => role == 'admin' ? 'مدير' : 'موظف استقبال';
}
