import '../../../../core/database/database_helper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/apartment_entity.dart';
import '../../domain/repositories/apartment_repository.dart';
import '../models/apartment_model.dart';

class ApartmentRepositoryImpl implements ApartmentRepository {
  final DatabaseHelper _dbHelper;

  ApartmentRepositoryImpl({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<ApartmentModel>> fetchAllApartments() async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query('apartments', orderBy: 'id DESC');
      return results.map((row) => ApartmentModel.fromMap(row)).toList();
    } catch (e) {
      throw DatabaseFailure('فشل تحميل الشقق من قاعدة البيانات: $e');
    }
  }

  @override
  Future<ApartmentModel?> fetchApartmentById(int id) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'apartments',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (results.isEmpty) return null;
      return ApartmentModel.fromMap(results.first);
    } catch (e) {
      throw DatabaseFailure('حدث خطأ أثناء تحميل تفاصيل الشقة: $e');
    }
  }

  @override
  Future<void> createApartment(ApartmentModel apartment) async {
    try {
      final db = await _dbHelper.database;
      final insertedId = await db.insert('apartments', apartment.toMap());

      await _dbHelper.insertAuditLog(
        userId: null, // set by controller layer in providers
        action: 'إضافة شقة جديدة: ${apartment.name}',
        entityType: 'apartments',
        entityId: insertedId,
      );
    } catch (e) {
      throw DatabaseFailure('فشلت عملية حفظ الشقة في قاعدة البيانات: $e');
    }
  }

  @override
  Future<void> updateApartment(ApartmentModel apartment) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'apartments',
        apartment.toMap(),
        where: 'id = ?',
        whereArgs: [apartment.id],
      );

      await _dbHelper.insertAuditLog(
        userId: null,
        action: 'تعديل بيانات الشقة: ${apartment.name}',
        entityType: 'apartments',
        entityId: apartment.id,
      );
    } catch (e) {
      throw DatabaseFailure('فشل تحديث الشقة في قاعدة البيانات: $e');
    }
  }

  @override
  Future<void> changeApartmentStatus(int apartmentId, ApartmentStatus status) async {
    try {
      final db = await _dbHelper.database;
      String statusStr = 'available';
      if (status == ApartmentStatus.occupied) statusStr = 'occupied';
      if (status == ApartmentStatus.cleaning) statusStr = 'cleaning';
      if (status == ApartmentStatus.maintenance) statusStr = 'maintenance';

      await db.update(
        'apartments',
        {'status': statusStr},
        where: 'id = ?',
        whereArgs: [apartmentId],
      );

      await _dbHelper.insertAuditLog(
        userId: null,
        action: 'تغيير حالة الشقة إلى: $statusStr',
        entityType: 'apartments',
        entityId: apartmentId,
      );
    } catch (e) {
      throw DatabaseFailure('فشل تحويل حالة الشقة: $e');
    }
  }

  @override
  Future<void> deleteApartment(int apartmentId, {required int adminUserId}) async {
    try {
      final db = await _dbHelper.database;
      
      // Perform deletion
      await db.delete(
        'apartments',
        where: 'id = ?',
        whereArgs: [apartmentId],
      );

      await _dbHelper.insertAuditLog(
        userId: adminUserId,
        action: 'حذف شقة نهائياً',
        entityType: 'apartments',
        entityId: apartmentId,
      );
    } catch (e) {
      throw DatabaseFailure('حدث خطأ أثناء محاولة حذف الشقة: $e');
    }
  }
}
