enum PaymentMethod {
  cash,
  bankTransfer,
  ccp,
  baridiMob,
}

class PaymentEntity {
  final int? id;
  final int bookingId;
  final double amount;
  final PaymentMethod paymentMethod;
  final DateTime paymentDate;
  final String? notes;

  const PaymentEntity({
    this.id,
    required this.bookingId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    this.notes,
  });

  String get paymentMethodString {
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.ccp:
        return 'CCP';
      case PaymentMethod.baridiMob:
        return 'BaridiMob';
    }
  }

  String get paymentMethodArabic {
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return 'نقداً (كاش)';
      case PaymentMethod.bankTransfer:
        return 'تحويل بنكي';
      case PaymentMethod.ccp:
        return 'حساب جاري CCP';
      case PaymentMethod.baridiMob:
        return ' تطبيق BaridiMob بريدي موب';
    }
  }
}
