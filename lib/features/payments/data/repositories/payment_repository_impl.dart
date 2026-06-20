import '../../../../core/database/database_helper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../models/payment_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final DatabaseHelper _dbHelper;

  PaymentRepositoryImpl({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<PaymentModel>> fetchAllPayments() async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'payments',
        orderBy: 'payment_date DESC',
      );
      return results.map((row) => PaymentModel.fromMap(row)).toList();
    } catch (e) {
      throw DatabaseFailure('فشل تحميل قائمة كافة المدفوعات التاريخية: $e');
    }
  }

  @override
  Future<List<PaymentModel>> fetchPaymentsForBooking(int bookingId) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'payments',
        where: 'booking_id = ?',
        whereArgs: [bookingId],
        orderBy: 'payment_date DESC',
      );
      return results.map((row) => PaymentModel.fromMap(row)).toList();
    } catch (e) {
      throw DatabaseFailure('فشل تحميل قائمة المدفوعات من قاعدة البيانات: $e');
    }
  }

  @override
  Future<double> fetchTotalPaidForBooking(int bookingId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM payments WHERE booking_id = ?',
        [bookingId],
      );
      final total = result.first['total'];
      return (total as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw DatabaseFailure('فشل حساب إجمالي المدفوعات للحجز: $e');
    }
  }

  @override
  Future<void> createPayment(PaymentModel payment) async {
    try {
      final db = await _dbHelper.database;
      final insertedId = await db.insert('payments', payment.toMap());

      await _dbHelper.insertAuditLog(
        userId: null,
        action: 'تسليم دفعة مالية بقيمة ${payment.amount} د.ج',
        entityType: 'payments',
        entityId: insertedId,
      );
    } catch (e) {
      throw DatabaseFailure('فشل تسجيل الدفعة في قاعدة البيانات: $e');
    }
  }
}
