import '../../../../core/database/database_helper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/guest_entity.dart';
import '../../domain/repositories/guest_repository.dart';
import '../models/guest_model.dart';

class GuestRepositoryImpl implements GuestRepository {
  final DatabaseHelper _dbHelper;

  GuestRepositoryImpl({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<GuestModel>> fetchAllGuests() async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query('guests', orderBy: 'full_name ASC');
      return results.map((row) => GuestModel.fromMap(row)).toList();
    } catch (e) {
      throw DatabaseFailure('فشلت عملية تحميل بيانات النزلاء: $e');
    }
  }

  @override
  Future<GuestModel?> fetchGuestById(int id) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'guests',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (results.isEmpty) return null;
      return GuestModel.fromMap(results.first);
    } catch (e) {
      throw DatabaseFailure('فشل العثور على ملف النزيل: $e');
    }
  }

  @override
  Future<int> createGuest(GuestModel guest) async {
    try {
      final db = await _dbHelper.database;
      final insertedId = await db.insert('guests', guest.toMap());

      await _dbHelper.insertAuditLog(
        userId: null,
        action: 'إضافة نزيل جديد: ${guest.fullName}',
        entityType: 'guests',
        entityId: insertedId,
      );
      return insertedId;
    } catch (e) {
      throw DatabaseFailure('فشل حفظ معلومات النزيل الجديد: $e');
    }
  }

  @override
  Future<void> updateGuest(GuestModel guest) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'guests',
        guest.toMap(),
        where: 'id = ?',
        whereArgs: [guest.id],
      );

      await _dbHelper.insertAuditLog(
        userId: null,
        action: 'تعديل ملف النزيل: ${guest.fullName}',
        entityType: 'guests',
        entityId: guest.id,
      );
    } catch (e) {
      throw DatabaseFailure('فشلت محاولة تعديل بيانات النزيل: $e');
    }
  }

  @override
  Future<void> deleteGuest(int id) async {
    try {
      final db = await _dbHelper.database;
      
      // Safety Check: check if the guest is associated with any bookings
      final associatedBookings = await db.query(
        'bookings',
        where: 'guest_id = ?',
        whereArgs: [id],
      );
      
      if (associatedBookings.isNotEmpty) {
        throw const DatabaseFailure('لا يمكن حذف هذا النزيل لأنه مرتبط بحجوزات مسبقة في النظام. يمكنك تعديل بياناته بدلاً من ذلك.');
      }
      
      // Get guest details first to log the action
      final guest = await fetchGuestById(id);
      final guestName = guest?.fullName ?? '#$id';

      await db.delete(
        'guests',
        where: 'id = ?',
        whereArgs: [id],
      );

      await _dbHelper.insertAuditLog(
        userId: null,
        action: 'حذف ملف النزيل: $guestName',
        entityType: 'guests',
        entityId: id,
      );
    } catch (e) {
      if (e is DatabaseFailure) rethrow;
      throw DatabaseFailure('فشلت محاولة حذف النزيل من النظام: $e');
    }
  }
}
