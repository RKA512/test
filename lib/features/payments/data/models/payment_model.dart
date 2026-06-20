import '../../domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    super.id,
    required super.bookingId,
    required super.amount,
    required super.paymentMethod,
    required super.paymentDate,
    super.notes,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    PaymentMethod parsedMethod = PaymentMethod.cash;
    final dbMethod = map['payment_method'] as String? ?? 'Cash';
    if (dbMethod == 'Bank Transfer' || dbMethod == 'bank_transfer') {
      parsedMethod = PaymentMethod.bankTransfer;
    } else if (dbMethod == 'CCP' || dbMethod == 'ccp') {
      parsedMethod = PaymentMethod.ccp;
    } else if (dbMethod == 'BaridiMob' || dbMethod == 'baridi_mob') {
      parsedMethod = PaymentMethod.baridiMob;
    }

    return PaymentModel(
      id: map['id'] as int?,
      bookingId: map['booking_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      paymentMethod: parsedMethod,
      paymentDate: DateTime.parse(map['payment_date'] as String),
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'booking_id': bookingId,
      'amount': amount,
      'payment_method': paymentMethodString,
      'payment_date': paymentDate.toIso8601String(),
      'notes': notes,
    };
  }
}
