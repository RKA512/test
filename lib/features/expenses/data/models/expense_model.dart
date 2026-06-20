import '../../domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    super.id,
    super.apartmentId,
    required super.amount,
    required super.expenseType,
    required super.description,
    required super.expenseDate,
    required super.createdBy,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      apartmentId: map['apartment_id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      expenseType: map['expense_type'] as String,
      description: map['description'] as String,
      expenseDate: DateTime.parse(map['expense_date'] as String),
      createdBy: map['created_by'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'apartment_id': apartmentId,
      'amount': amount,
      'expense_type': expenseType,
      'description': description,
      'expense_date': expenseDate.toIso8601String().split('T')[0],
      'created_by': createdBy,
    };
  }
}
