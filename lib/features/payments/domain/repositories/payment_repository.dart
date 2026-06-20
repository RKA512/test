import '../../../../core/error/failures.dart';
import '../entities/payment_entity.dart';
import '../../data/models/payment_model.dart';

abstract class PaymentRepository {
  Future<List<PaymentEntity>> fetchPaymentsForBooking(int bookingId);
  Future<List<PaymentEntity>> fetchAllPayments();
  Future<double> fetchTotalPaidForBooking(int bookingId);
  Future<void> createPayment(PaymentModel payment);
}
