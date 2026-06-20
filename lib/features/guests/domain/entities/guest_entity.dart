class GuestEntity {
  final int? id;
  final String fullName;
  final String phone;
  final String idCardNumber;
  final String nationality;
  final String? notes;
  final DateTime createdAt;

  const GuestEntity({
    this.id,
    required this.fullName,
    required this.phone,
    required this.idCardNumber,
    required this.nationality,
    this.notes,
    required this.createdAt,
  });
}
