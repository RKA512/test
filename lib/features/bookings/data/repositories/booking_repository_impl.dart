import '../../../../core/database/database_helper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../models/booking_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final DatabaseHelper _dbHelper;

  BookingRepositoryImpl({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<BookingModel>> fetchAllBookings() async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query('bookings', orderBy: 'check_in_date DESC');
      return results.map((row) => BookingModel.fromMap(row)).toList();
    } catch (e) {
      throw DatabaseFailure('فشل جلب قائمة الحجوزات: $e');
    }
  }

  @override
  Future<List<BookingModel>> fetchBookingsByApartment(int apartmentId) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'bookings',
        where: 'apartment_id = ? AND status != ?',
        whereArgs: [apartmentId, 'cancelled'],
        orderBy: 'check_in_date ASC',
      );
      return results.map((row) => BookingModel.fromMap(row)).toList();
    } catch (e) {
      throw DatabaseFailure('فشل جلب حجوزات الشقة: $e');
    }
  }

  @override
  Future<bool> checkOverlappingBooking({
    required int apartmentId,
    required DateTime checkIn,
    required DateTime checkOut,
    int? excludeBookingId,
  }) async {
    try {
      final db = await _dbHelper.database;
      final checkInStr = checkIn.toIso8601String().split('T')[0];
      final checkOutStr = checkOut.toIso8601String().split('T')[0];

      // Standard logical overlap: (check_in_date < checkOutStr AND check_out_date > checkInStr)
      // Exclude cancelled bookings and optionally the booking itself when updating
      // We use COALESCE and substr to fall back to actual_checkout_datetime if status is 'completed'
      String query = '''
        SELECT COUNT(*) as count FROM bookings 
        WHERE apartment_id = ? 
          AND status != 'cancelled'
          AND (
            check_in_date < ? AND 
            COALESCE(NULLIF(substr(actual_checkout_datetime, 1, 10), ''), check_out_date) > ?
          )
      ''';

      List<dynamic> args = [apartmentId, checkOutStr, checkInStr];

      if (excludeBookingId != null) {
        query += ' AND id != ?';
        args.add(excludeBookingId);
      }

      final results = await db.rawQuery(query, args);
      final count = results.first['count'] as int? ?? 0;

      return count > 0;
    } catch (e) {
      throw DatabaseFailure('خطأ أثناء فحص تداخل الحجوزات: $e');
    }
  }

  @override
  Future<void> createBooking(BookingModel booking) async {
    try {
      final db = await _dbHelper.database;

      // Perform final safety check against concurrent overlaps
      final hasOverlap = await checkOverlappingBooking(
        apartmentId: booking.apartmentId,
        checkIn: booking.checkInDate,
        checkOut: booking.checkOutDate,
      );

      if (hasOverlap) {
        throw const DoubleBookingFailure(
            'تنبيه تعارض: الشقة محجوزة بالفعل من قبل نزيل آخر في نفس التواريخ المحددة.');
      }

      final insertedId = await db.insert('bookings', booking.toMap());

      await _dbHelper.insertAuditLog(
        userId: null,
        action: 'إنشاء حجز جديد برقم #${booking.bookingNumber}',
        entityType: 'bookings',
        entityId: insertedId,
      );

      // Sync the apartment status
      await _syncApartmentStatus(db, booking.apartmentId);
    } catch (e) {
      if (e is DoubleBookingFailure) rethrow;
      throw DatabaseFailure('فشلت عملية حفظ الحجز الجديد: $e');
    }
  }

  @override
  Future<void> updateBooking(BookingModel booking) async {
    try {
      final db = await _dbHelper.database;

      // Perform overlap check excluding current booking
      final hasOverlap = await checkOverlappingBooking(
        apartmentId: booking.apartmentId,
        checkIn: booking.checkInDate,
        checkOut: booking.checkOutDate,
        excludeBookingId: booking.id,
      );

      if (hasOverlap) {
        throw const DoubleBookingFailure(
            'تنبيه تعارض: تعديل الحجز يتعارض مع حجوزات مؤكدة أخرى بالشقة.');
      }

      // Fetch old booking to check if the apartment changed
      final oldBookingRows = await db.query(
        'bookings',
        columns: ['apartment_id'],
        where: 'id = ?',
        whereArgs: [booking.id],
      );
      int? oldApartmentId;
      if (oldBookingRows.isNotEmpty) {
        oldApartmentId = oldBookingRows.first['apartment_id'] as int?;
      }

      await db.update(
        'bookings',
        booking.toMap(),
        where: 'id = ?',
        whereArgs: [booking.id],
      );

      await _dbHelper.insertAuditLog(
        userId: null,
        action: 'تعديل حجز برقم #${booking.bookingNumber}',
        entityType: 'bookings',
        entityId: booking.id,
      );

      // Sync both old and new apartments
      if (oldApartmentId != null && oldApartmentId != booking.apartmentId) {
        await _syncApartmentStatus(db, oldApartmentId);
      }
      await _syncApartmentStatus(db, booking.apartmentId);
    } catch (e) {
      if (e is DoubleBookingFailure) rethrow;
      throw DatabaseFailure('فشل تحديث بيانات الحجز: $e');
    }
  }

  @override
  Future<void> updateBookingStatus({
    required int bookingId,
    required BookingStatus status,
    DateTime? checkInTime,
    DateTime? checkOutTime,
  }) async {
    try {
      final db = await _dbHelper.database;

      // Fetch apartment id and booking data before update
      final bookingRows = await db.query(
        'bookings',
        columns: [
          'apartment_id',
          'check_in_date',
          'check_out_date',
          'price_per_night',
          'deposit_amount'
        ],
        where: 'id = ?',
        whereArgs: [bookingId],
      );
      int? apartmentId;
      if (bookingRows.isNotEmpty) {
        apartmentId = bookingRows.first['apartment_id'] as int?;
      }

      String statusStr = 'confirmed';
      if (status == BookingStatus.pendingArrival) statusStr = 'pending_arrival';
      if (status == BookingStatus.checkedIn) statusStr = 'checked_in';
      if (status == BookingStatus.completed) statusStr = 'completed';
      if (status == BookingStatus.cancelled) statusStr = 'cancelled';

      final Map<String, dynamic> updates = {'status': statusStr};

      if (checkInTime != null) {
        updates['actual_checkin_datetime'] = checkInTime.toIso8601String();
      }
      if (checkOutTime != null) {
        updates['actual_checkout_datetime'] = checkOutTime.toIso8601String();

        // Recalculate nights and total price on completed/ checkout:
        if (status == BookingStatus.completed && bookingRows.isNotEmpty) {
          final checkInStr = bookingRows.first['check_in_date'] as String;
          final checkInDate = DateTime.parse(checkInStr);
          final actualCheckOutDate =
              DateTime(checkOutTime.year, checkOutTime.month, checkOutTime.day);

          int actualNights = actualCheckOutDate.difference(checkInDate).inDays;
          if (actualNights < 1) actualNights = 1;

          final pricePerNight =
              (bookingRows.first['price_per_night'] as num).toDouble();
          final depositAmount =
              (bookingRows.first['deposit_amount'] as num).toDouble();

          final newTotalPrice = actualNights * pricePerNight;
          final newRemainingAmount =
              (newTotalPrice - depositAmount).clamp(0.0, double.infinity);

          updates['check_out_date'] =
              actualCheckOutDate.toIso8601String().split('T')[0];
          updates['total_price'] = newTotalPrice;
          updates['remaining_amount'] = newRemainingAmount;
        }
      }

      await db.update(
        'bookings',
        updates,
        where: 'id = ?',
        whereArgs: [bookingId],
      );

      await _dbHelper.insertAuditLog(
        userId: null,
        action: 'تغيير حالة حجز إلى: $statusStr',
        entityType: 'bookings',
        entityId: bookingId,
      );

      // Sync the apartment status
      if (apartmentId != null) {
        await _syncApartmentStatus(db, apartmentId);
      }
    } catch (e) {
      throw DatabaseFailure('فشل تحديث حالة الحجز: $e');
    }
  }

  @override
  Future<void> cancelBooking(int bookingId) async {
    try {
      final db = await _dbHelper.database;

      // Fetch apartment id before update
      final bookingRows = await db.query(
        'bookings',
        columns: ['apartment_id'],
        where: 'id = ?',
        whereArgs: [bookingId],
      );
      int? apartmentId;
      if (bookingRows.isNotEmpty) {
        apartmentId = bookingRows.first['apartment_id'] as int?;
      }

      await db.update(
        'bookings',
        {'status': 'cancelled'},
        where: 'id = ?',
        whereArgs: [bookingId],
      );

      await _dbHelper.insertAuditLog(
        userId: null,
        action: 'إلغاء حجز نهائياً',
        entityType: 'bookings',
        entityId: bookingId,
      );

      // Sync the apartment status
      if (apartmentId != null) {
        await _syncApartmentStatus(db, apartmentId);
      }
    } catch (e) {
      throw DatabaseFailure('فشل إلغاء الحجز من النظام: $e');
    }
  }

  // Method to sync apartment status based on actual active bookings in database.
  Future<void> _syncApartmentStatus(dynamic db, int apartmentId) async {
    // Determine active bookings for this apartment
    final activeBookings = await db.query(
      'bookings',
      where: 'apartment_id = ? AND status IN (?, ?, ?)',
      whereArgs: [apartmentId, 'confirmed', 'pending_arrival', 'checked_in'],
    );

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    bool isCurrentlyOccupied = false;

    for (var b in activeBookings) {
      final status = b['status'] as String;
      if (status == 'checked_in') {
        isCurrentlyOccupied = true;
        break;
      }

      final checkInStr = b['check_in_date'] as String;
      final checkOutStr = b['check_out_date'] as String;

      final checkInDate = DateTime.parse(checkInStr);
      final checkOutDate = DateTime.parse(checkOutStr);

      final checkInDay =
          DateTime(checkInDate.year, checkInDate.month, checkInDate.day);
      final checkOutDay =
          DateTime(checkOutDate.year, checkOutDate.month, checkOutDate.day);

      // Today is within [checkInDay, checkOutDay)
      if ((today.isAfter(checkInDay) || today.isAtSameMomentAs(checkInDay)) &&
          today.isBefore(checkOutDay)) {
        isCurrentlyOccupied = true;
        break;
      }
    }

    if (isCurrentlyOccupied) {
      await db.update(
        'apartments',
        {'status': 'occupied'},
        where: 'id = ?',
        whereArgs: [apartmentId],
      );
    } else {
      // Fetch the apartment's current status
      final aptRows = await db.query(
        'apartments',
        columns: ['status'],
        where: 'id = ?',
        whereArgs: [apartmentId],
      );

      if (aptRows.isNotEmpty) {
        final currentStatus = aptRows.first['status'] as String;

        // If the apartment is currently marked occupied but has no occupying active booking,
        // we should determine if it should transition to 'cleaning' or directly to 'available'.
        if (currentStatus == 'occupied') {
          // Check if there was a booking completed/checked out today
          final completedBookings = await db.query(
            'bookings',
            where: 'apartment_id = ? AND status = ?',
            whereArgs: [apartmentId, 'completed'],
          );

          bool wasCheckedOutToday = false;
          for (var b in completedBookings) {
            String? checkOutStr = b['check_out_date'] as String?;
            String? actualCheckOutStr =
                b['actual_checkout_datetime'] as String?;

            if (actualCheckOutStr != null && actualCheckOutStr.isNotEmpty) {
              final actualCheckOut = DateTime.parse(actualCheckOutStr);
              if (actualCheckOut.year == today.year &&
                  actualCheckOut.month == today.month &&
                  actualCheckOut.day == today.day) {
                wasCheckedOutToday = true;
                break;
              }
            } else if (checkOutStr != null && checkOutStr.isNotEmpty) {
              final checkOutDate = DateTime.parse(checkOutStr);
              if (checkOutDate.year == today.year &&
                  checkOutDate.month == today.month &&
                  checkOutDate.day == today.day) {
                wasCheckedOutToday = true;
                break;
              }
            }
          }

          if (wasCheckedOutToday) {
            await db.update(
              'apartments',
              {'status': 'cleaning'},
              where: 'id = ?',
              whereArgs: [apartmentId],
            );
          } else {
            await db.update(
              'apartments',
              {'status': 'available'},
              where: 'id = ?',
              whereArgs: [apartmentId],
            );
          }
        }
      }
    }
  }
}
