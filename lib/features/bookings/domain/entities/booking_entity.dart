enum BookingStatus {
  confirmed,
  pendingArrival,
  checkedIn,
  completed,
  cancelled,
}

class BookingEntity {
  final int? id;
  final String bookingNumber;
  final int guestId;
  final int apartmentId;
  final int guestsCount;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final DateTime? actualCheckInDateTime;
  final DateTime? actualCheckOutDateTime;
  final BookingStatus status;
  final double pricePerNight;
  final double totalPrice;
  final double depositAmount;
  final double remainingAmount;
  final String? notes;
  final DateTime createdAt;

  const BookingEntity({
    this.id,
    required this.bookingNumber,
    required this.guestId,
    required this.apartmentId,
    required this.guestsCount,
    required this.checkInDate,
    required this.checkOutDate,
    this.actualCheckInDateTime,
    this.actualCheckOutDateTime,
    required this.status,
    required this.pricePerNight,
    required this.totalPrice,
    required this.depositAmount,
    required this.remainingAmount,
    this.notes,
    required this.createdAt,
  });

  String get statusString {
    switch (status) {
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.pendingArrival:
        return 'pending_arrival';
      case BookingStatus.checkedIn:
        return 'checked_in';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.cancelled:
        return 'cancelled';
    }
  }

  String get statusArabic {
    switch (status) {
      case BookingStatus.confirmed:
        return 'مؤكد وجهوزي';
      case BookingStatus.pendingArrival:
        return 'حجز قيد الوصول اليوم';
      case BookingStatus.checkedIn:
        return 'أتم الدخول (مقيم حالياً)';
      case BookingStatus.completed:
        return 'مكتمل الخروج والتسليم';
      case BookingStatus.cancelled:
        return 'ملغى وتصفية حسابات';
    }
  }

  int get nightsCount {
    return checkOutDate.difference(checkInDate).inDays;
  }
}
