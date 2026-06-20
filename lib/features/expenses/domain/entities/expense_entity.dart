class ExpenseEntity {
  final int? id;
  final int? apartmentId; // Nullable if general expense
  final double amount;
  final String expenseType; // 'cleaning_material', 'repairs', 'general_bills', etc.
  final String description;
  final DateTime expenseDate;
  final int createdBy;

  const ExpenseEntity({
    this.id,
    this.apartmentId,
    required this.amount,
    required this.expenseType,
    required this.description,
    required this.expenseDate,
    required this.createdBy,
  });

  String get expenseTypeArabic {
    switch (expenseType) {
      case 'cleaning':
        return 'مواد ومصاريف تنظيف';
      case 'repairs':
        return 'تصليحات وصيانة';
      case 'utilities':
        return 'فواتير (ماء، كهرباء، إنترنت)';
      case 'laundry':
        return 'غسيل وكوي الشراشف';
      default:
        return 'مصاريف عامة متنوعة';
    }
  }
}
