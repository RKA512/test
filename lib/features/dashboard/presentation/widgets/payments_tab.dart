import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/providers/app_providers.dart';
import '../../../payments/domain/entities/payment_entity.dart';

class PaymentsTab extends ConsumerStatefulWidget {
  const PaymentsTab({super.key});

  @override
  ConsumerState<PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends ConsumerState<PaymentsTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(paymentsProvider);
    final bookingsList = ref.watch(bookingsProvider).value ?? [];
    final guestsList = ref.watch(guestsProvider).value ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: null, // Unified screen
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سجل المدفوعات والتحصيل المالي',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Color(0xFF1E293B),
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'استعراض وتفصيل الإيرادات المالية والدفعات المستلمة من النزلاء',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
                // Refresh button
                IconButton(
                  icon: const Icon(Icons.refresh_rounded,
                      color: Color(0xFF4F46E5)),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  onPressed: () {
                    ref.read(paymentsProvider.notifier).loadAllPayments();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Bar Card
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200, width: 0.5),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: TextField(
                  controller: _searchController,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    hintText:
                        'البحث عن دفعة برقم الحجز أو اسم النزيل أو المبلغ...',
                    hintStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                        fontFamily: 'Tajawal'),
                    border: InputBorder.none,
                    prefixIcon:
                        Icon(Icons.search, size: 20, color: Colors.blueGrey),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List of Payments Table
            Expanded(
              child: paymentsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Text(
                    'تعذر تحميل المدفوعات: $err',
                    style: const TextStyle(
                        color: Colors.red, fontFamily: 'Tajawal'),
                  ),
                ),
                data: (payments) {
                  // Filter payments based on search query
                  final filteredPayments = payments.where((p) {
                    if (_searchQuery.isEmpty) return true;

                    // Match amount
                    if (p.amount.toString().contains(_searchQuery)) return true;

                    // Match booking sequence/number
                    final booking = bookingsList.firstWhere(
                      (b) => b.id == p.bookingId,
                      orElse: () => _emptyBooking(),
                    );
                    if (booking.bookingNumber
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase())) {
                      return true;
                    }

                    // Match guest name
                    final guest = guestsList.firstWhere(
                      (g) => g.id == booking.guestId,
                      orElse: () => _emptyGuest(),
                    );
                    if (guest.fullName
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase())) {
                      return true;
                    }

                    return false;
                  }).toList();

                  if (filteredPayments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payments_outlined,
                              size: 60, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          const Text(
                            'لا توجد سجلات مدفوعات متطابقة',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200, width: 0.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(
                                const Color(0xFFF8FAFC)),
                            horizontalMargin: 16,
                            columnSpacing: 24,
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'رقم الحجز المرجعي',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                      fontFamily: 'Tajawal'),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'النزيل المستفيد',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                      fontFamily: 'Tajawal'),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'المبلغ المستلم',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                      fontFamily: 'Tajawal'),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'تاريخ السداد والتحصيل',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                      fontFamily: 'Tajawal'),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'قناة السداد التلقائي',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                      fontFamily: 'Tajawal'),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'ملاحظات وبيان الدفعة',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                      fontFamily: 'Tajawal'),
                                ),
                              ),
                            ],
                            rows: filteredPayments.map((p) {
                              final booking = bookingsList.firstWhere(
                                (b) => b.id == p.bookingId,
                                orElse: () => _emptyBooking(),
                              );
                              final guest = guestsList.firstWhere(
                                (g) => g.id == booking.guestId,
                                orElse: () => _emptyGuest(),
                              );

                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      booking.id == null
                                          ? 'غير متوفر'
                                          : booking.bookingNumber,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo,
                                          fontFamily: 'Tajawal'),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      guest.fullName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Tajawal'),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECFDF5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '+ ${p.amount.toStringAsFixed(0)} د.ج',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF059669),
                                          fontFamily: 'Tajawal',
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      intl.DateFormat('yyyy/MM/dd HH:mm')
                                          .format(p.paymentDate),
                                      style: const TextStyle(
                                          fontFamily: 'Tajawal'),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _getPaymentMethodArabic(p.paymentMethod),
                                      style: const TextStyle(
                                          fontFamily: 'Tajawal'),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      p.notes ?? 'لا توجد ملاحظات على الدفعة',
                                      style: const TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize: 12,
                                          fontFamily: 'Tajawal'),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fallbacks to prevent null reference breaking rendering
  dynamic _emptyBooking() {
    return _MockBooking();
  }

  dynamic _emptyGuest() {
    return _MockGuest();
  }

  String _getPaymentMethodArabic(dynamic method) {
    return 'نقداً (Cash)';
  }
}

class _MockBooking {
  final int? id = null;
  final String bookingNumber = 'غير موجود';
  final int guestId = -1;
}

class _MockGuest {
  final int? id = null;
  final String fullName = 'نزيل غير مسجل';
}
