import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/providers/app_providers.dart';
import '../../../bookings/domain/entities/booking_entity.dart';
import '../../../apartments/domain/entities/apartment_entity.dart';
import '../../../payments/domain/entities/payment_entity.dart';

// Helper model to hold comprehensive apartment metrics
class AptPerformance {
  final ApartmentEntity apartment;
  final int bookingsCount;
  final int nightsCount;
  final double revenue;
  final double expenses;
  final double netProfit;
  final double occupancyRate;

  AptPerformance({
    required this.apartment,
    required this.bookingsCount,
    required this.nightsCount,
    required this.revenue,
    required this.expenses,
    required this.netProfit,
    required this.occupancyRate,
  });
}

class ReportsTab extends ConsumerStatefulWidget {
  const ReportsTab({super.key});

  @override
  ConsumerState<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends ConsumerState<ReportsTab> {
  String _selectedFilter = 'month'; // 'today', 'month', 'year', 'custom'
  String _selectedSort = 'default'; // 'default', 'profit_desc'
  DateTime _customStartDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _customEndDate = DateTime.now();

  bool isDateInRange(DateTime date, DateTime start, DateTime end) {
    final d = DateTime(date.year, date.month, date.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return (d.isAtSameMomentAs(s) || d.isAfter(s)) &&
        (d.isAtSameMomentAs(e) || d.isBefore(e));
  }

  // True if [checkIn, checkOut] overlaps with the filter period [start, end]
  bool isOverlapping(
      DateTime checkIn, DateTime checkOut, DateTime start, DateTime end) {
    final bStart = DateTime(checkIn.year, checkIn.month, checkIn.day);
    final bEnd = DateTime(checkOut.year, checkOut.month, checkOut.day);
    final fStart = DateTime(start.year, start.month, start.day);
    final fEnd = DateTime(end.year, end.month, end.day);
    return (bStart.isBefore(fEnd) || bStart.isAtSameMomentAs(fEnd)) &&
        (bEnd.isAfter(fStart) || bEnd.isAtSameMomentAs(fStart));
  }

  int getOverlapNights(DateTime checkIn, DateTime checkOut,
      DateTime filterStart, DateTime filterEnd) {
    final bStart = DateTime(checkIn.year, checkIn.month, checkIn.day);
    final bEnd = DateTime(checkOut.year, checkOut.month, checkOut.day);
    final fStart =
        DateTime(filterStart.year, filterStart.month, filterStart.day);
    final fEnd = DateTime(filterEnd.year, filterEnd.month, filterEnd.day);

    final overlapStart = bStart.isAfter(fStart) ? bStart : fStart;
    final overlapEnd = bEnd.isBefore(fEnd) ? bEnd : fEnd;

    if (overlapEnd.isAfter(overlapStart)) {
      return overlapEnd.difference(overlapStart).inDays;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(bookingsProvider).value ?? [];
    final apartments = ref.watch(apartmentsProvider).value ?? [];
    final expenses = ref.watch(expensesProvider).value ?? [];
    final payments = ref.watch(paymentsProvider).value ?? [];

    // Calculate filter dates
    DateTime start;
    DateTime end;
    final now = DateTime.now();

    switch (_selectedFilter) {
      case 'today':
        start = DateTime(now.year, now.month, now.day, 0, 0, 0);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'month':
        start = DateTime(now.year, now.month, 1, 0, 0, 0);
        end = DateTime(now.year, now.month + 1, 1, 23, 59, 59)
            .subtract(const Duration(days: 1));
        break;
      case 'year':
        start = DateTime(now.year, 1, 1, 0, 0, 0);
        end = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
      case 'custom':
      default:
        start = DateTime(_customStartDate.year, _customStartDate.month,
            _customStartDate.day, 0, 0, 0);
        end = DateTime(_customEndDate.year, _customEndDate.month,
            _customEndDate.day, 23, 59, 59);
        break;
    }

    int totalDaysInPeriod = end.difference(start).inDays + 1;
    if (totalDaysInPeriod <= 0) totalDaysInPeriod = 1;

    // --- Dynamic financial indicator calculations with proportional scaling ---
    double totalExpected = 0.0;
    double totalRemaining = 0.0;

    for (var b in bookings) {
      if (b.status != BookingStatus.cancelled) {
        final bOut = b.actualCheckOutDateTime ?? b.checkOutDate;
        final overlapNights = getOverlapNights(b.checkInDate, bOut, start, end);
        if (overlapNights > 0) {
          final nightlyRate =
              b.nightsCount > 0 ? (b.totalPrice / b.nightsCount) : 0.0;
          final expectedInPeriod = nightlyRate * overlapNights;
          totalExpected += expectedInPeriod;

          final remainingRatio =
              b.totalPrice > 0 ? (b.remainingAmount / b.totalPrice) : 0.0;
          totalRemaining += expectedInPeriod * remainingRatio;
        }
      }
    }

    // 2. Collected Revenue (الإيرادات المحصلة): Sum of payments in the period
    final filteredPayments = payments
        .where((p) => isDateInRange(p.paymentDate, start, end))
        .toList();
    double totalCollected =
        filteredPayments.fold(0.0, (sum, p) => sum + p.amount);

    // 3. Uncollected Amounts (المبالغ المتبقية غير المحصلة): is totalRemaining computed proportionally
    // 4. Total Expenses (إجمالي المصاريف) in the period
    final filteredExpenses = expenses
        .where((exp) => isDateInRange(exp.expenseDate, start, end))
        .toList();
    double totalExpenses =
        filteredExpenses.fold(0.0, (sum, exp) => sum + exp.amount);

    // 5. Net Profit (صافي الربح) in the period
    double netProfit = totalCollected - totalExpenses;

    // 6. Occupancy rate in the period based on overlap nights for all rooms
    int totalBookedNights = 0;
    for (var b in bookings) {
      if (b.status != BookingStatus.cancelled) {
        final bOut = b.actualCheckOutDateTime ?? b.checkOutDate;
        totalBookedNights += getOverlapNights(b.checkInDate, bOut, start, end);
      }
    }

    double occupancyRate = 0.0;
    if (apartments.isNotEmpty) {
      int totalPotentialNights = apartments.length * totalDaysInPeriod;
      occupancyRate = (totalBookedNights / totalPotentialNights) * 100;
      if (occupancyRate > 100.0) occupancyRate = 100.0;
    }

    // Historical Bookings matching period using overlap rule
    final listBookings = bookings
        .where((b) =>
            b.status != BookingStatus.cancelled &&
            isOverlapping(b.checkInDate,
                b.actualCheckOutDateTime ?? b.checkOutDate, start, end))
        .toList();

    // --- Construct Apartment Performance Data ---
    final List<AptPerformance> performances = [];
    for (var apt in apartments) {
      // Bookings overlapping with filter period for this apartment
      final aptBookingsInPeriod = bookings
          .where((b) =>
              b.apartmentId == apt.id &&
              b.status != BookingStatus.cancelled &&
              isOverlapping(b.checkInDate,
                  b.actualCheckOutDateTime ?? b.checkOutDate, start, end))
          .toList();

      final bookingsCount = aptBookingsInPeriod.length;

      // Actual overlapping nights spent in this apartment inside filter period
      final nightsCount = bookings
          .where((b) =>
              b.apartmentId == apt.id && b.status != BookingStatus.cancelled)
          .fold<int>(
              0,
              (sum, b) =>
                  sum +
                  getOverlapNights(b.checkInDate,
                      b.actualCheckOutDateTime ?? b.checkOutDate, start, end));

      // Payments received within the period for any booking of this apartment
      final aptBookingIds = bookings
          .where((b) => b.apartmentId == apt.id)
          .map((b) => b.id)
          .toSet();
      final apartmentRevenue = payments
          .where((p) =>
              aptBookingIds.contains(p.bookingId) &&
              isDateInRange(p.paymentDate, start, end))
          .fold<double>(0.0, (sum, p) => sum + p.amount);

      // Expenses linked specifically to this apartment during filter period
      final apartmentExpenses = expenses
          .where((exp) =>
              exp.apartmentId == apt.id &&
              isDateInRange(exp.expenseDate, start, end))
          .fold<double>(0.0, (sum, exp) => sum + exp.amount);

      final apartmentNetProfit = apartmentRevenue - apartmentExpenses;

      double aptOccupancy = 0.0;
      if (totalDaysInPeriod > 0) {
        aptOccupancy = (nightsCount / totalDaysInPeriod) * 100;
        if (aptOccupancy > 100.0) aptOccupancy = 100.0;
      }

      performances.add(AptPerformance(
        apartment: apt,
        bookingsCount: bookingsCount,
        nightsCount: nightsCount,
        revenue: apartmentRevenue,
        expenses: apartmentExpenses,
        netProfit: apartmentNetProfit,
        occupancyRate: aptOccupancy,
      ));
    }

    // Sort by net profit if chosen
    if (_selectedSort == 'profit_desc') {
      performances.sort((a, b) => b.netProfit.compareTo(a.netProfit));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'التقارير والإحصائيات الشاملة',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Filter Selector Widget
            _buildFilterSelector(context),
            const SizedBox(height: 16),

            // Separate financial indicators title
            const Text(
              'المؤشرات المالية الأساسية للفترة المحددة:',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: Color(0xFF1E293B)),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),

            // Grid of indicators
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.end,
              children: [
                _buildMetricCard(
                  title: 'الإيرادات المتوقعة',
                  value: '${totalExpected.toStringAsFixed(0)} د.ج',
                  subtitle: 'تناسبياً مع ليالي الفلترة الكلية',
                  icon: Icons.assignment_outlined,
                  color: Colors.blue,
                  width: 260,
                ),
                _buildMetricCard(
                  title: 'الإيرادات المحصلة',
                  value: '${totalCollected.toStringAsFixed(0)} د.ج',
                  subtitle: 'النقدية المستلمة والمسجلة فعلياً',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF10B981),
                  width: 260,
                ),
                _buildMetricCard(
                  title: 'المبالغ المتبقية غير المحصلة',
                  value: '${totalRemaining.toStringAsFixed(0)} د.ج',
                  subtitle: 'تناسبي مستحق معلق في ذمة النزلاء',
                  icon: Icons.hourglass_empty,
                  color: Colors.orange,
                  width: 260,
                ),
                _buildMetricCard(
                  title: 'إجمالي المصاريف والتشغيل',
                  value: '${totalExpenses.toStringAsFixed(0)} د.ج',
                  subtitle: 'نفقات الصيانة، الفواتير والخدمات',
                  icon: Icons.trending_down,
                  color: Colors.redAccent,
                  width: 260,
                ),
                _buildMetricCard(
                  title: 'صافي الربح الفعلي',
                  value: '${netProfit.toStringAsFixed(0)} د.ج',
                  subtitle: 'الفارق النقدي (المحصل - المصاريف)',
                  icon: Icons.monetization_on_outlined,
                  color: Colors.indigo,
                  width: 260,
                ),
                _buildMetricCard(
                  title: 'معدل شغل الشقق الفعلي',
                  value: '${occupancyRate.toStringAsFixed(1)}%',
                  subtitle:
                      'إشغال: $totalBookedNights ليلة من أصل ${apartments.isEmpty ? 0 : apartments.length * totalDaysInPeriod} ليلة',
                  icon: Icons.bedroom_parent,
                  color: Colors.purple,
                  width: 260,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Performance section header with custom sorting toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSortOptions(),
                const Text(
                  'أداء وعائدات الشقق الفردية خلال الفترة:',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: Color(0xFF1E293B)),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Performance list
            if (apartments.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'لا توجد شقق مسجلة في هذا النظام حالياً.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: performances.length,
                itemBuilder: (ctx, idx) {
                  final perf = performances[idx];
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'إشغال: ${perf.occupancyRate.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: Colors.indigo),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    perf.apartment.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        color: Color(0xFF1E293B)),
                                  ),
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.grey.shade100,
                                    child: Text(
                                      '${idx + 1}',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          GridView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1.8,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            children: [
                              _buildSubMetric(
                                  'عدد الحجوزات',
                                  '${perf.bookingsCount} حجز',
                                  Icons.book_online,
                                  Colors.blue),
                              _buildSubMetric(
                                  'عدد الليالي',
                                  '${perf.nightsCount} ليلة',
                                  Icons.nights_stay,
                                  Colors.teal),
                              _buildSubMetric(
                                  'إيرادات محصلة',
                                  '${perf.revenue.toStringAsFixed(0)} د.ج',
                                  Icons.arrow_upward,
                                  Colors.green),
                              _buildSubMetric(
                                  'المصاريف الخاصة',
                                  '${perf.expenses.toStringAsFixed(0)} د.ج',
                                  Icons.arrow_downward,
                                  Colors.redAccent),
                              _buildSubMetric(
                                  'الربح الصافي',
                                  '${perf.netProfit.toStringAsFixed(0)} د.ج',
                                  Icons.monetization_on,
                                  Colors.indigo),
                              _buildSubMetric(
                                  'الحالة المستمرة',
                                  perf.apartment.statusArabic,
                                  Icons.info_outline,
                                  Colors.orange),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),

            // History table list in period
            const Text(
              'الحجوزات النشطة والمتداخلة مع الفترة المحددة:',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: Color(0xFF1E293B)),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: listBookings.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                          child: Text('لا توجد حجوزات متداخلة خلال هذه الفترة.',
                              style: TextStyle(color: Colors.grey))),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: listBookings.length,
                      separatorBuilder: (ctx, idx) => const Divider(height: 1),
                      itemBuilder: (ctx, idx) {
                        final b = listBookings[idx];

                        // Safe implementation avoiding "orElse: () => apartments.first" crashing on empty
                        final targetApt = apartments.firstWhere(
                          (apt) => apt.id == b.apartmentId,
                          orElse: () => ApartmentEntity(
                            id: b.apartmentId,
                            name: 'شقة غير معروفة أو محذوفة',
                            roomsCount: 0,
                            bedsCount: 0,
                            maxCapacity: 0,
                            basePrice: 0.0,
                            status: ApartmentStatus.available,
                            createdAt: DateTime.now(),
                          ),
                        );

                        return ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${b.totalPrice.toStringAsFixed(0)} د.ج',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 13),
                              ),
                              Text(
                                'حجز رقم: #${b.bookingNumber}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'من ${intl.DateFormat('yyyy/MM/dd').format(b.checkInDate)} لغاية ${intl.DateFormat('yyyy/MM/dd').format(b.actualCheckOutDateTime ?? b.checkOutDate)}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.blueGrey),
                              ),
                              Text(
                                '${targetApt.name} - ${b.statusArabic}',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: _getStatusColor(b.status)),
                              ),
                            ],
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

  Widget _buildSubMetric(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 12),
              Text(
                label,
                style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions() {
    return Row(
      children: [
        ChoiceChip(
          label: Text(
            'الأكثر ربحية',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color:
                  _selectedSort == 'profit_desc' ? Colors.white : Colors.indigo,
            ),
          ),
          selected: _selectedSort == 'profit_desc',
          onSelected: (selected) {
            setState(() {
              _selectedSort = selected ? 'profit_desc' : 'default';
            });
          },
          selectedColor: Colors.indigo,
          backgroundColor: Colors.white,
          side: BorderSide(
              color: _selectedSort == 'profit_desc'
                  ? Colors.indigo
                  : Colors.grey.shade300),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: Text(
            'الافتراضي',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _selectedSort == 'default' ? Colors.white : Colors.indigo,
            ),
          ),
          selected: _selectedSort == 'default',
          onSelected: (selected) {
            setState(() {
              _selectedSort = selected ? 'default' : 'profit_desc';
            });
          },
          selectedColor: Colors.indigo,
          backgroundColor: Colors.white,
          side: BorderSide(
              color: _selectedSort == 'default'
                  ? Colors.indigo
                  : Colors.grey.shade300),
        ),
      ],
    );
  }

  Widget _buildFilterSelector(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                _buildFilterButton('custom', 'فترة مخصصة'),
                _buildFilterButton('year', 'هذه السنة'),
                _buildFilterButton('month', 'هذا الشهر'),
                _buildFilterButton('today', 'اليوم'),
              ].reversed.toList(),
            ),
            if (_selectedFilter == 'custom') ...[
              const Divider(height: 16),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: _customEndDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (selected != null) {
                            setState(() {
                              _customEndDate = selected;
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_today, size: 14),
                        label: Text(
                          'إلى: ${intl.DateFormat('yyyy/MM/dd').format(_customEndDate)}',
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.indigo,
                          side: const BorderSide(color: Colors.indigo),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: _customStartDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (selected != null) {
                            setState(() {
                              _customStartDate = selected;
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_today, size: 14),
                        label: Text(
                          'من: ${intl.DateFormat('yyyy/MM/dd').format(_customStartDate)}',
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.indigo,
                          side: const BorderSide(color: Colors.indigo),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = filter;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.indigo : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF64748B),
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return const Color(0xFF4F46E5);
      case BookingStatus.pendingArrival:
        return Colors.orange;
      case BookingStatus.checkedIn:
        return Colors.green;
      case BookingStatus.completed:
        return Colors.grey;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double width,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}
