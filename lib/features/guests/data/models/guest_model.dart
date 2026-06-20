import '../../domain/entities/guest_entity.dart';

class GuestModel extends GuestEntity {
  const GuestModel({
    super.id,
    required super.fullName,
    required super.phone,
    required super.idCardNumber,
    required super.nationality,
    super.notes,
    required super.createdAt,
  });

  factory GuestModel.fromMap(Map<String, dynamic> map) {
    return GuestModel(
      id: map['id'] as int?,
      fullName: map['full_name'] as String,
      phone: map['phone'] as String,
      idCardNumber: map['id_card_number'] as String,
      nationality: map['nationality'] as String,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'full_name': fullName,
      'phone': phone,
      'id_card_number': idCardNumber,
      'nationality': nationality,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
