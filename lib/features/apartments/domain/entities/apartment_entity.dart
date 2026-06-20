enum ApartmentStatus {
  available,
  occupied,
  cleaning,
  maintenance,
}

class ApartmentEntity {
  final int? id;
  final String name;
  final int roomsCount;
  final int bedsCount;
  final int maxCapacity;
  final double basePrice;
  final String? notes;
  final ApartmentStatus status;
  final DateTime createdAt;

  const ApartmentEntity({
    this.id,
    required this.name,
    required this.roomsCount,
    required this.bedsCount,
    required this.maxCapacity,
    required this.basePrice,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  String get statusString {
    switch (status) {
      case ApartmentStatus.available:
        return 'available';
      case ApartmentStatus.occupied:
        return 'occupied';
      case ApartmentStatus.cleaning:
        return 'cleaning';
      case ApartmentStatus.maintenance:
        return 'maintenance';
    }
  }

  String get statusArabic {
    switch (status) {
      case ApartmentStatus.available:
        return 'شاغرة (جاهزة)';
      case ApartmentStatus.occupied:
        return 'مشغولة حالياً';
      case ApartmentStatus.cleaning:
        return 'قيد التنظيف';
      case ApartmentStatus.maintenance:
        return 'تحت الصيانة';
    }
  }
}
