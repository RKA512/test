import '../../domain/entities/apartment_entity.dart';

class ApartmentModel extends ApartmentEntity {
  const ApartmentModel({
    super.id,
    required super.name,
    required super.roomsCount,
    required super.bedsCount,
    required super.maxCapacity,
    required super.basePrice,
    super.notes,
    required super.status,
    required super.createdAt,
  });

  factory ApartmentModel.fromMap(Map<String, dynamic> map) {
    // Parse status securely
    ApartmentStatus parsedStatus = ApartmentStatus.available;
    final dbStatus = map['status'] as String? ?? 'available';
    if (dbStatus == 'occupied') {
      parsedStatus = ApartmentStatus.occupied;
    } else if (dbStatus == 'cleaning') {
      parsedStatus = ApartmentStatus.cleaning;
    } else if (dbStatus == 'maintenance') {
      parsedStatus = ApartmentStatus.maintenance;
    }

    return ApartmentModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      roomsCount: map['rooms_count'] as int,
      bedsCount: map['beds_count'] as int,
      maxCapacity: map['max_capacity'] as int,
      basePrice: (map['base_price'] as num).toDouble(),
      notes: map['notes'] as String?,
      status: parsedStatus,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'rooms_count': roomsCount,
      'beds_count': bedsCount,
      'max_capacity': maxCapacity,
      'base_price': basePrice,
      'notes': notes,
      'status': statusString,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
