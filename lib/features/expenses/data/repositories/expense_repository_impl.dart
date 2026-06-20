import '../../../../core/database/database_helper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final DatabaseHelper _dbHelper;

  ExpenseRepositoryImpl({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<ExpenseModel>> fetchAllExpenses() async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query('expenses', orderBy: 'expense_date DESC');
      return results.map((row) => ExpenseModel.fromMap(row)).toList();
    } catch (e) {
      throw DatabaseFailure('فشل جلب قائمة المصاريف والنفقات المحددة: $e');
    }
  }

  @override
  Future<void> createExpense(ExpenseModel expense) async {
    try {
      final db = await _dbHelper.database;
      final insertedId = await db.insert('expenses', expense.toMap());

      await _dbHelper.insertAuditLog(
        userId: expense.createdBy,
        action: 'تسجيل منصرف مالي: ${expense.description}',
        entityType: 'expenses',
        entityId: insertedId,
      );
    } catch (e) {
      throw DatabaseFailure('فشل تسجيل المبلع المنصرف في النظام: $e');
    }
  }

  @override
  Future<void> deleteExpense(int id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('expenses', where: 'id = ?', whereArgs: [id]);

      await _dbHelper.insertAuditLog(
        userId: null,
        action: 'حذف منصرف مالي نهائياً',
        entityType: 'expenses',
        entityId: id,
      );
    } catch (e) {
      throw DatabaseFailure('لم تنجح إزالة المصروف المحدد: $e');
    }
  }
}
