import '../../../../core/error/failures.dart';
import '../entities/booking_entity.dart';
import '../../data/models/booking_model.dart';

abstract class BookingRepository {
  Future<List<BookingEntity>> fetchAllBookings();

  Future<List<BookingEntity>> fetchBookingsByApartment(int apartmentId);

  Future<bool> checkOverlappingBooking({
    required int apartmentId,
    required DateTime checkIn,
    required DateTime checkOut,
    int? excludeBookingId,
  });

  Future<void> createBooking(BookingModel booking);

  Future<void> updateBooking(BookingModel booking);

  Future<void> updateBookingStatus({
    required int bookingId,
    required BookingStatus status,
    DateTime? checkInTime,
    DateTime? checkOutTime,
  });

  Future<void> cancelBooking(int bookingId);
}
