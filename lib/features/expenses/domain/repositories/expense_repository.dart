import '../../../../core/error/failures.dart';
import '../entities/expense_entity.dart';
import '../../data/models/expense_model.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseEntity>> fetchAllExpenses();
  Future<void> createExpense(ExpenseModel expense);
  Future<void> deleteExpense(int id);
}
