import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/providers/app_providers.dart';
import '../../../apartments/domain/entities/apartment_entity.dart';
import '../../../bookings/domain/entities/booking_entity.dart';
import 'booking_dialogs.dart';

class CalendarTab extends ConsumerStatefulWidget {
  const CalendarTab({super.key});

  @override
  ConsumerState<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends ConsumerState<CalendarTab> {
  int _selectedViewDays = 14; // Default to 14 days view
  DateTime _startDate = DateTime.now()
      .subtract(const Duration(days: 2)); // Start slightly in past for context

  @override
  Widget build(BuildContext context) {
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final bookingsAsync = ref.watch(bookingsProvider);
    final guestsAsync = ref.watch(guestsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: null, // Removed nested conflicting AppBar
      body: apartmentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
            child: Text('حدث خطأ: $err',
                style: const TextStyle(color: Colors.red))),
        data: (apartments) {
          return bookingsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) =>
                Center(child: Text('خطأ في تحميل الحجوزات: $err')),
            data: (bookings) {
              // Prepare active columns (list of dates to render)
              final dates = List.generate(_selectedViewDays, (index) {
                return _startDate.add(Duration(days: index));
              });

              return Column(
                children: [
                  // Beautiful Visible View Duration Selectors Row & Today Action
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    child: Card(
                      elevation: 0,
                      color: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side:
                            BorderSide(color: Colors.grey.shade200, width: 0.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'فترة العرض المحتسبة:',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                      fontFamily: 'Tajawal'),
                                ),
                                const SizedBox(width: 12),
                                _buildDurationButton(14, '14 يوماً'),
                                const SizedBox(width: 6),
                                _buildDurationButton(30, '30 يوماً'),
                                const SizedBox(width: 6),
                                _buildDurationButton(90, '90 يوماً'),
                              ],
                            ),
                            // Today Reset Action button (RTL aligned)
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _startDate = DateTime.now()
                                      .subtract(const Duration(days: 2));
                                });
                              },
                              icon: const Icon(Icons.today_rounded,
                                  size: 16, color: Color(0xFF4F46E5)),
                              label: const Text('اليوم',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF4F46E5),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Tajawal')),
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFFEEF2FF),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Calendar Navigation Bar
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _startDate = _startDate.subtract(
                                  Duration(days: _selectedViewDays ~/ 2));
                            });
                          },
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('السابق'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.indigo,
                          ),
                        ),
                        Text(
                          'من ${intl.DateFormat('yyyy/MM/dd').format(_startDate)} إلى ${intl.DateFormat('yyyy/MM/dd').format(dates.last)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF334155)),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _startDate = _startDate
                                  .add(Duration(days: _selectedViewDays ~/ 2));
                            });
                          },
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          label: const Text('التالي'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Interactive Grid
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildGridTable(
                            context, apartments, bookings, dates),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGridTable(
    BuildContext context,
    List<ApartmentEntity> apartments,
    List<BookingEntity> bookings,
    List<DateTime> dates,
  ) {
    const double cellWidth = 100.0;
    const double rowHeaderWidth = 150.0;
    const double cellHeight = 65.0;

    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      border: TableBorder.all(color: Colors.grey.shade200, width: 0.5),
      children: [
        // Table Header (Dates row)
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
          children: [
            // Safe alignment corner space
            Container(
              width: rowHeaderWidth,
              height: cellHeight,
              alignment: Alignment.center,
              child: const Text(
                'الشقق الفندقية / الموعد',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Color(0xFF475569)),
              ),
            ),
            ...dates.map((date) {
              final isToday = date.day == DateTime.now().day &&
                  date.month == DateTime.now().month &&
                  date.year == DateTime.now().year;

              return Container(
                width: cellWidth,
                height: cellHeight,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isToday ? Colors.indigo.shade50 : null,
                  border: isToday
                      ? Border(
                          bottom: BorderSide(
                              color: Colors.indigo.shade600, width: 2))
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getArabicDayName(date.weekday),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                        color: isToday
                            ? Colors.indigo.shade800
                            : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      intl.DateFormat('dd MMM').format(date),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: isToday
                            ? Colors.indigo.shade900
                            : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),

        // Apartments Rows
        ...apartments.map((apartment) {
          return TableRow(
            children: [
              // Apartment Name Column Header
              Container(
                width: rowHeaderWidth,
                height: cellHeight,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.centerRight,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      apartment.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${apartment.basePrice.toStringAsFixed(0)} د.ج / ليلة',
                      style: const TextStyle(
                          fontSize: 10,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // Calendar Days Cells
              ...dates.map((date) {
                // Determine if this cell falls under a booking checkin/checkout date
                final booking =
                    _getBookingForDate(bookings, apartment.id!, date);

                final isToday = date.day == DateTime.now().day &&
                    date.month == DateTime.now().month &&
                    date.year == DateTime.now().year;

                if (booking != null) {
                  // Render a booking reservation visual card
                  return InkWell(
                    onTap: () =>
                        _inspectBookingDetails(context, booking, apartment),
                    child: Container(
                      width: cellWidth,
                      height: cellHeight,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: _getBookingColor(booking.status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'حجز #${booking.bookingNumber}\n${booking.statusArabic}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ),
                  );
                }

                // Empty slot -> Allows booking creation
                return InkWell(
                  onTap: () => _openNewBookingForm(context, apartment, date),
                  child: Container(
                    width: cellWidth,
                    height: cellHeight,
                    color: isToday
                        ? Colors.indigo.withOpacity(0.02)
                        : Colors.white,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.add_circle_outline_rounded,
                      color: Colors.grey.withOpacity(0.2),
                      size: 20,
                    ),
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  // Find booking that encompasses the given date for a specific apartment
  BookingEntity? _getBookingForDate(
      List<BookingEntity> bookings, int apartmentId, DateTime date) {
    for (var b in bookings) {
      if (b.apartmentId == apartmentId && b.status != BookingStatus.cancelled) {
        // Date must fall between checkInDate (inclusive) and effective checkOutDate (exclusive)
        final dayOnly = DateTime(date.year, date.month, date.day);
        final checkInDay = DateTime(
            b.checkInDate.year, b.checkInDate.month, b.checkInDate.day);

        final effectiveCheckOut = b.actualCheckOutDateTime ?? b.checkOutDate;
        final checkOutDay = DateTime(effectiveCheckOut.year,
            effectiveCheckOut.month, effectiveCheckOut.day);

        if ((dayOnly.isAfter(checkInDay) ||
                dayOnly.isAtSameMomentAs(checkInDay)) &&
            dayOnly.isBefore(checkOutDay)) {
          return b;
        }
      }
    }
    return null;
  }

  Color _getBookingColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return const Color(0xFF4F46E5); // Indigo
      case BookingStatus.pendingArrival:
        return const Color(0xFFF59E0B); // Amber
      case BookingStatus.checkedIn:
        return const Color(0xFF10B981); // Emerald Green
      case BookingStatus.completed:
        return const Color(0xFF64748B); // Slate Gray
      case BookingStatus.cancelled:
        return const Color(0xFFEF4444); // Red
    }
  }

  String _getArabicDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'الإثنين';
      case DateTime.tuesday:
        return 'الثلاثاء';
      case DateTime.wednesday:
        return 'الأربعاء';
      case DateTime.thursday:
        return 'الخميس';
      case DateTime.friday:
        return 'الجمعة';
      case DateTime.saturday:
        return 'السبت';
      case DateTime.sunday:
        return 'الأحد';
      default:
        return '';
    }
  }

  void _inspectBookingDetails(
      BuildContext context, BookingEntity booking, ApartmentEntity apartment) {
    showDialog(
      context: context,
      builder: (context) =>
          BookingInspectorDialog(booking: booking, apartment: apartment),
    );
  }

  void _openNewBookingForm(
      BuildContext context, ApartmentEntity apartment, DateTime requestedDate) {
    showDialog(
      context: context,
      builder: (context) => CreateBookingDialog(
        apartment: apartment,
        preselectedCheckInDate: requestedDate,
      ),
    );
  }

  Widget _buildDurationButton(int days, String label) {
    final isSelected = _selectedViewDays == days;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : const Color(0xFF64748B),
          fontFamily: 'Tajawal',
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF4F46E5),
      backgroundColor: const Color(0xFFF1F5F9),
      showCheckmark: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (val) {
        if (val) {
          setState(() {
            _selectedViewDays = days;
          });
        }
      },
    );
  }
}
