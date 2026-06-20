import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    super.id,
    required super.bookingNumber,
    required super.guestId,
    required super.apartmentId,
    required super.guestsCount,
    required super.checkInDate,
    required super.checkOutDate,
    super.actualCheckInDateTime,
    super.actualCheckOutDateTime,
    required super.status,
    required super.pricePerNight,
    required super.totalPrice,
    required super.depositAmount,
    required super.remainingAmount,
    super.notes,
    required super.createdAt,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    // Parse Status
    BookingStatus statusEnum = BookingStatus.confirmed;
    final dbStatus = map['status'] as String? ?? 'confirmed';
    if (dbStatus == 'pending_arrival') {
      statusEnum = BookingStatus.pendingArrival;
    } else if (dbStatus == 'checked_in') {
      statusEnum = BookingStatus.checkedIn;
    } else if (dbStatus == 'completed') {
      statusEnum = BookingStatus.completed;
    } else if (dbStatus == 'cancelled') {
      statusEnum = BookingStatus.cancelled;
    }

    return BookingModel(
      id: map['id'] as int?,
      bookingNumber: map['booking_number'] as String,
      guestId: map['guest_id'] as int,
      apartmentId: map['apartment_id'] as int,
      guestsCount: map['guests_count'] as int,
      checkInDate: DateTime.parse(map['check_in_date'] as String),
      checkOutDate: DateTime.parse(map['check_out_date'] as String),
      actualCheckInDateTime: map['actual_checkin_datetime'] != null
          ? DateTime.parse(map['actual_checkin_datetime'] as String)
          : null,
      actualCheckOutDateTime: map['actual_checkout_datetime'] != null
          ? DateTime.parse(map['actual_checkout_datetime'] as String)
          : null,
      status: statusEnum,
      pricePerNight: (map['price_per_night'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0.0,
      depositAmount: (map['deposit_amount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (map['remaining_amount'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'booking_number': bookingNumber,
      'guest_id': guestId,
      'apartment_id': apartmentId,
      'guests_count': guestsCount,
      'check_in_date': checkInDate.toIso8601String().split('T')[0],
      'check_out_date': checkOutDate.toIso8601String().split('T')[0],
      'actual_checkin_datetime': actualCheckInDateTime?.toIso8601String(),
      'actual_checkout_datetime': actualCheckOutDateTime?.toIso8601String(),
      'status': statusString,
      'price_per_night': pricePerNight,
      'total_price': totalPrice,
      'deposit_amount': depositAmount,
      'remaining_amount': remainingAmount,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
