import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:uuid/uuid.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../apartments/domain/entities/apartment_entity.dart';
import '../../../bookings/domain/entities/booking_entity.dart';
import '../../../bookings/data/models/booking_model.dart';
import '../../../guests/domain/entities/guest_entity.dart';
import '../../../guests/data/models/guest_model.dart';
import '../../../payments/data/models/payment_model.dart';
import '../../../payments/domain/entities/payment_entity.dart';

// Dialog for INSPECTING, CANCELLING, or CHECKING-IN a booking
class BookingInspectorDialog extends ConsumerStatefulWidget {
  final BookingEntity booking;
  final ApartmentEntity apartment;

  const BookingInspectorDialog({
    super.key,
    required this.booking,
    required this.apartment,
  });

  @override
  ConsumerState<BookingInspectorDialog> createState() =>
      _BookingInspectorDialogState();
}

class _BookingInspectorDialogState
    extends ConsumerState<BookingInspectorDialog> {
  GuestEntity? _guest;
  bool _isLoadingGuest = true;
  double _totalPaid = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final guestRepo = ref.read(guestRepositoryProvider);
      final g = await guestRepo.fetchGuestById(widget.booking.guestId);
      final payRepo = ref.read(paymentRepositoryProvider);
      final paid = await payRepo.fetchTotalPaidForBooking(widget.booking.id!);

      if (mounted) {
        setState(() {
          _guest = g;
          _totalPaid = paid;
          _isLoadingGuest = false;
        });
      }
    } catch (_) {
      setState(() => _isLoadingGuest = false);
    }
  }

  Future<void> _handleCheckIn() async {
    // Save Actual Arrival Date as NOW
    await ref.read(bookingsProvider.notifier).updateStatus(
          bookingId: widget.booking.id!,
          status: BookingStatus.checkedIn,
          checkInTime: DateTime.now(),
        );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('تم تسجيل دخول النزيل رسمياً للشقة الفندقية.')),
      );
    }
  }

  Future<void> _handleCheckOut() async {
    // Save Actual Check-Out Date as NOW
    await ref.read(bookingsProvider.notifier).updateStatus(
          bookingId: widget.booking.id!,
          status: BookingStatus.completed,
          checkOutTime: DateTime.now(),
        );

    // Prompt user if they want to log an additional payment if there's any remaining debt
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'تم تسجيل المغادرة والتسليم، وتغيير حالة الشقة قيد التنظيف والتهيئة.')),
      );
    }
  }

  Future<void> _handleCancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الإلغاء', textAlign: TextAlign.right),
        content: const Text('هل أنت متأكد من رغبتك في إلغاء هذا الحجز بالكامل؟',
            textAlign: TextAlign.right),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('تراجع')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('تأكيد الإلغاء'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(bookingsProvider.notifier)
          .cancelBooking(widget.booking.id!);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إلغاء الحجز لتاريخ الحجز المذكور.')),
        );
      }
    }
  }

  Future<void> _addPaymentDialog() async {
    final amountController = TextEditingController(
      text: (widget.booking.totalPrice - _totalPaid)
          .clamp(0.0, double.infinity)
          .toStringAsFixed(0),
    );
    PaymentMethod selectedMethod = PaymentMethod.cash;

    final success = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('تسجيل دفعة مالية جديدة',
                textAlign: TextAlign.right),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('المبلغ المدفوع (د.ج) *',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 12),
                const Text('طريقة الدفع المعتمدة',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<PaymentMethod>(
                  value: selectedMethod,
                  isExpanded: true,
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedMethod = val);
                  },
                  items: PaymentMethod.values.map((method) {
                    // Friendly Arabic payment label
                    String name = 'كاش نقدي';
                    if (method == PaymentMethod.bankTransfer)
                      name = 'تحويل بنكي خارجي';
                    if (method == PaymentMethod.ccp) name = 'حساب جاري CCP';
                    if (method == PaymentMethod.baridiMob)
                      name = 'بريدي موب BaridiMob';
                    return DropdownMenuItem(
                        value: method,
                        child: Text(name, textAlign: TextAlign.right));
                  }).toList(),
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () async {
                  final amt = double.tryParse(amountController.text) ?? 0.0;
                  if (amt <= 0) return;

                  final payload = PaymentModel(
                    bookingId: widget.booking.id!,
                    amount: amt,
                    paymentMethod: selectedMethod,
                    paymentDate: DateTime.now(),
                    notes: 'دفعة تسوية إضافية',
                  );

                  await ref.read(paymentsProvider.notifier).addPayment(payload);
                  if (ctx.mounted) Navigator.pop(ctx, true);
                },
                child: const Text('تسجيل الدفعة'),
              )
            ],
          );
        },
      ),
    );

    if (success == true) {
      _loadDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingGuest) {
      return const AlertDialog(
        content: SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final remaining = widget.booking.totalPrice - _totalPaid;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'تفاصيل حجز #${widget.booking.bookingNumber}',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Safe general details
            _buildInfoRow('الشقة الفندقية', widget.apartment.name),
            _buildInfoRow('النزيل المستأجر', _guest?.fullName ?? 'غير معروف'),
            _buildInfoRow('رقم هاتف النزيل', _guest?.phone ?? 'غير متوفر'),
            _buildInfoRow(
                'عدد النزلاء الفعلي', '${widget.booking.guestsCount} أشخاص'),
            const Divider(),
            _buildInfoRow(
                'تاريخ الدخول المتوقع',
                intl.DateFormat('yyyy/MM/dd')
                    .format(widget.booking.checkInDate)),
            _buildInfoRow(
                'تاريخ الخروج المتوقع',
                intl.DateFormat('yyyy/MM/dd')
                    .format(widget.booking.checkOutDate)),
            _buildInfoRow(
                'الدخول الفعلي بالنظام',
                widget.booking.actualCheckInDateTime != null
                    ? intl.DateFormat('yyyy/MM/dd HH:mm')
                        .format(widget.booking.actualCheckInDateTime!)
                    : 'معلق لم يتم الدخول'),
            _buildInfoRow(
                'الخروج الفعلي بالنظام',
                widget.booking.actualCheckOutDateTime != null
                    ? intl.DateFormat('yyyy/MM/dd HH:mm')
                        .format(widget.booking.actualCheckOutDateTime!)
                    : 'معلق لم يتم المغادرة في السجلات'),
            const Divider(),
            _buildInfoRow('سعر الليلة المتفق عليه',
                '${widget.booking.pricePerNight.toStringAsFixed(0)} د.ج',
                isBold: true),
            _buildInfoRow('السعر الإجمالي للحجز',
                '${widget.booking.totalPrice.toStringAsFixed(0)} د.ج',
                isBold: true),
            _buildInfoRow('المبلغ المدفوع تراكمياً',
                '${_totalPaid.toStringAsFixed(0)} د.ج',
                color: Colors.green, isBold: true),
            _buildInfoRow('المتبقي المالي العالي',
                '${remaining.clamp(0.0, double.infinity).toStringAsFixed(0)} د.ج',
                color: remaining > 0 ? Colors.red : Colors.green, isBold: true),
            if (widget.booking.notes != null &&
                widget.booking.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('ملاحظات المبيت والاستقبال:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(widget.booking.notes!,
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
            ],

            const SizedBox(height: 24),

            // Dynamic control buttons based on state
            if (widget.booking.status == BookingStatus.confirmed ||
                widget.booking.status == BookingStatus.pendingArrival) ...[
              ElevatedButton.icon(
                onPressed: _handleCheckIn,
                icon: const Icon(Icons.login),
                label: const Text('تسجيل دخول النزيل للشقة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 8),
            ],

            if (widget.booking.status == BookingStatus.checkedIn) ...[
              ElevatedButton.icon(
                onPressed: _handleCheckOut,
                icon: const Icon(Icons.logout),
                label: const Text('تسجيل خروج النزيل وإخلاء الشقة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 8),
            ],

            if (remaining > 0 &&
                widget.booking.status != BookingStatus.cancelled &&
                widget.booking.status != BookingStatus.completed) ...[
              OutlinedButton.icon(
                onPressed: _addPaymentDialog,
                icon: const Icon(Icons.add_card_rounded),
                label: const Text('تسجيل دفعة إضافية'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 8),
            ],

            if (widget.booking.status == BookingStatus.confirmed ||
                widget.booking.status == BookingStatus.pendingArrival ||
                widget.booking.status == BookingStatus.checkedIn) ...[
              OutlinedButton.icon(
                onPressed: () async {
                  final success = await showDialog<bool>(
                    context: context,
                    builder: (ctx) =>
                        EditBookingDialog(booking: widget.booking),
                  );
                  if (success == true && mounted) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.edit, color: Colors.indigo),
                label: const Text('تعديل الحجز بالكامل'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.indigo),
                ),
              ),
              const SizedBox(height: 8),
            ],

            if (widget.booking.status != BookingStatus.completed &&
                widget.booking.status != BookingStatus.cancelled) ...[
              ElevatedButton.icon(
                onPressed: _handleCancel,
                icon: const Icon(Icons.cancel, color: Colors.white),
                label: const Text('إلغاء حجز النزيل بالكامل'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? const Color(0xFF1E293B),
              fontSize: 13,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// Dialog for CREATING a booking
class CreateBookingDialog extends ConsumerStatefulWidget {
  final ApartmentEntity apartment;
  final DateTime? preselectedCheckInDate;

  const CreateBookingDialog({
    super.key,
    required this.apartment,
    this.preselectedCheckInDate,
  });

  @override
  ConsumerState<CreateBookingDialog> createState() =>
      _CreateBookingDialogState();
}

class _CreateBookingDialogState extends ConsumerState<CreateBookingDialog> {
  final _bookingFormKey = GlobalKey<FormState>();

  // Booking details
  DateTime _checkInDate = DateTime.now();
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 1));
  int _guestsCount = 1;
  double _pricePerNight = 0.0;
  double _totalPriceState = 0.0;
  double _depositAmount = 0.0;
  String _notes = '';

  // Controllers for editable financial inputs
  late TextEditingController _pricePerNightController;
  late TextEditingController _totalPriceController;
  late TextEditingController _nightsCountController;

  // Guest settings
  bool _createNewGuest = false;
  GuestEntity? _selectedExistingGuest;

  // New Guest Form Fields
  final _newGuestNameController = TextEditingController();
  final _newGuestPhoneController = TextEditingController();
  final _newGuestIdCardController = TextEditingController();
  final _newGuestNationalityController = TextEditingController(text: 'جزائرية');
  final _newGuestNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pricePerNight = widget.apartment.basePrice;
    if (widget.preselectedCheckInDate != null) {
      _checkInDate = widget.preselectedCheckInDate!;
      _checkOutDate = _checkInDate.add(const Duration(days: 1));
    }
    _totalPriceState = _pricePerNight * _nightsCount;
    _pricePerNightController =
        TextEditingController(text: _pricePerNight.toStringAsFixed(0));
    _totalPriceController =
        TextEditingController(text: _totalPriceState.toStringAsFixed(0));
    _nightsCountController =
        TextEditingController(text: _nightsCount.toString());
  }

  @override
  void dispose() {
    _newGuestNameController.dispose();
    _newGuestPhoneController.dispose();
    _newGuestIdCardController.dispose();
    _newGuestNationalityController.dispose();
    _newGuestNotesController.dispose();
    _pricePerNightController.dispose();
    _totalPriceController.dispose();
    _nightsCountController.dispose();
    super.dispose();
  }

  int get _nightsCount {
    final difference = _checkOutDate.difference(_checkInDate).inDays;
    return difference <= 0 ? 1 : difference;
  }

  void _recalculateTotal() {
    setState(() {
      _totalPriceState = _pricePerNight * _nightsCount;
      _totalPriceController.text = _totalPriceState.toStringAsFixed(0);
      final currentNightsStr = _nightsCount.toString();
      if (_nightsCountController.text != currentNightsStr) {
        _nightsCountController.text = currentNightsStr;
      }
    });
  }

  double get _remainingAmount {
    return (_totalPriceState - _depositAmount).clamp(0.0, double.infinity);
  }

  void _onNightsCountChanged(String val) {
    final nights = int.tryParse(val) ?? 1;
    if (nights > 0) {
      setState(() {
        _checkOutDate = _checkInDate.add(Duration(days: nights));
        _recalculateTotal();
      });
    }
  }

  Future<void> _selectCheckInDate() async {
    final chosen = await showDatePicker(
      context: context,
      initialDate: _checkInDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (chosen != null) {
      setState(() {
        _checkInDate = chosen;
        final nights = int.tryParse(_nightsCountController.text) ?? 1;
        _checkOutDate = _checkInDate.add(Duration(days: nights));
        _recalculateTotal();
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    final chosen = await showDatePicker(
      context: context,
      initialDate: _checkOutDate,
      firstDate: _checkInDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (chosen != null) {
      setState(() {
        _checkOutDate = chosen;
        _recalculateTotal();
      });
    }
  }

  Future<void> _saveBooking() async {
    if (!_bookingFormKey.currentState!.validate()) return;

    try {
      final guestNotifier = ref.read(guestsProvider.notifier);
      final bookingNotifier = ref.read(bookingsProvider.notifier);

      int guestId;

      if (_createNewGuest) {
        // Create Guest Model
        final newGuest = GuestModel(
          fullName: _newGuestNameController.text.trim(),
          phone: _newGuestPhoneController.text.trim(),
          idCardNumber: _newGuestIdCardController.text.trim(),
          nationality: _newGuestNationalityController.text.trim(),
          notes: _newGuestNotesController.text.trim(),
          createdAt: DateTime.now(),
        );
        guestId = await guestNotifier.createGuest(newGuest);
      } else {
        if (_selectedExistingGuest == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'يرجى تحديد نزيل حالي مسجل مسبقاً أو تفعيل حقل نزيل جديد.')),
          );
          return;
        }
        guestId = _selectedExistingGuest!.id!;
      }

      // Prepare Unique Booking Number
      final bookingNumber =
          'BKG-' + const Uuid().v4().substring(0, 8).toUpperCase();

      final bookingModel = BookingModel(
        bookingNumber: bookingNumber,
        guestId: guestId,
        apartmentId: widget.apartment.id!,
        guestsCount: _guestsCount,
        checkInDate: _checkInDate,
        checkOutDate: _checkOutDate,
        status: BookingStatus.confirmed,
        pricePerNight: _pricePerNight,
        totalPrice: _totalPriceState,
        depositAmount: _depositAmount,
        remainingAmount: _remainingAmount,
        notes: _notes,
        createdAt: DateTime.now(),
      );

      await bookingNotifier.createBooking(bookingModel);

      // If deposit amount is typed, register an initial payment history
      if (_depositAmount > 0) {
        // Find newly registered booking in provider to link properly
        final latestBookings = ref.read(bookingsProvider).value ?? [];
        final linkedBkg =
            latestBookings.firstWhere((b) => b.bookingNumber == bookingNumber);

        await ref.read(paymentsProvider.notifier).addPayment(PaymentModel(
              bookingId: linkedBkg.id!,
              amount: _depositAmount,
              paymentMethod: PaymentMethod.cash,
              paymentDate: DateTime.now(),
              notes: 'عربون مسبق عند إنشاء الحجز',
            ));
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('تم تسجيل حجز الشقة وتأمين الدفعة بنجاح والمزامنة.')),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('تعذر إتمام الحجز', textAlign: TextAlign.right),
          content: Text(e.toString(), textAlign: TextAlign.right),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('حسناً')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final guestsList = ref.watch(guestsProvider).value ?? [];

    return AlertDialog(
      scrollable: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'تسجيل حجز جديد مخصص',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ],
      ),
      content: Form(
        key: _bookingFormKey,
        child: Container(
          width: 500,
          constraints: const BoxConstraints(maxWidth: 550),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display Chosen Apartment
              Container(
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.apartment.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                          fontSize: 13),
                    ),
                    const Text('شقة فندقية محددة:',
                        style: TextStyle(color: Colors.blueGrey, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Guests Source Mode Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ChoiceChip(
                    label: const Text('إدخال نزيل جديد'),
                    selected: _createNewGuest == true,
                    onSelected: (val) => setState(() => _createNewGuest = true),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('نزيل مسجل مسبقاً'),
                    selected: _createNewGuest == false,
                    onSelected: (val) =>
                        setState(() => _createNewGuest = false),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (!_createNewGuest) ...[
                // Dropdown to select existing guests
                const Text('تحديد النزيل من القائمة *',
                    textAlign: TextAlign.right,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                DropdownButtonFormField<GuestEntity>(
                  value: _selectedExistingGuest,
                  isExpanded: true,
                  hint: const Text('اختر النزيل المسجل مسبقاً',
                      textDirection: TextDirection.rtl),
                  items: guestsList.map((g) {
                    return DropdownMenuItem<GuestEntity>(
                      value: g,
                      child: Text('${g.fullName} - ${g.phone}',
                          textDirection: TextDirection.rtl),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedExistingGuest = val;
                    });
                  },
                ),
              ] else ...[
                // Forms to input New Guest
                const Text('بيانات النزيل الجديد الفورية:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.indigo)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _newGuestNameController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                      labelText: 'الاسم الكامل للنزيل *',
                      alignLabelWithHint: true),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'يرجى كتابة اسم النزيل بالكامل'
                      : null,
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _newGuestPhoneController,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.right,
                  decoration:
                      const InputDecoration(labelText: 'رقم الهاتف للنزيل *'),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'يرجى تسجيل رقم الهاتف'
                      : null,
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _newGuestIdCardController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                      labelText: 'رقم بطاقة الهوية الوطنية (اختياري)'),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _newGuestNationalityController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(labelText: 'الجنسية *'),
                ),
              ],

              const Divider(height: 32),

              // Booking details inputs
              const Text('معلومات السكن الإضافية:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.indigo)),
              const SizedBox(height: 8),

              // Dates inputs
              Row(
                children: [
                  // Check-Out Date (Manual / Auto updated)
                  Expanded(
                    child: InkWell(
                      onTap: _selectCheckOutDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'تاريخ المغادرة',
                          labelStyle: TextStyle(fontSize: 12),
                        ),
                        child: Text(
                          intl.DateFormat('yyyy/MM/dd').format(_checkOutDate),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Number of Nights Input
                  Expanded(
                    child: TextFormField(
                      controller: _nightsCountController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        labelText: 'عدد ليالي الإقامة',
                        labelStyle: TextStyle(fontSize: 12),
                      ),
                      onChanged: _onNightsCountChanged,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Check-In Date
                  Expanded(
                    child: InkWell(
                      onTap: _selectCheckInDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'تاريخ الدخول',
                          labelStyle: TextStyle(fontSize: 12),
                        ),
                        child: Text(
                          intl.DateFormat('yyyy/MM/dd').format(_checkInDate),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  // Guests count (Optional)
                  Expanded(
                    child: TextFormField(
                      initialValue: _guestsCount.toString(),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                          labelText: 'عدد الأشخاص (اختياري)'),
                      validator: (val) {
                        if (val != null && val.trim().isNotEmpty) {
                          final parsed = int.tryParse(val);
                          if (parsed == null || parsed <= 0) {
                            return 'يجب أن يكون العدد 1 على الأقل';
                          }
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          _guestsCount = int.tryParse(val) ?? 1;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Customized Price per Night override
                  Expanded(
                    child: TextFormField(
                      controller: _pricePerNightController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                          labelText: 'سعر الليلة (د.ج) *'),
                      validator: (val) {
                        if (val == null || val.isEmpty)
                          return 'يرجى كتابة السعر';
                        if (double.tryParse(val) == null)
                          return 'قيمة غير معتمدة';
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          _pricePerNight = double.tryParse(val) ??
                              widget.apartment.basePrice;
                          _recalculateTotal();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Symmetrical input for Manual OVERRIDE on Total Price
              TextFormField(
                controller: _totalPriceController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'السعر الإجمالي المعتمد للحجز (د.ج) *',
                  helperText:
                      'يمكن تعديل السعر الإجمالي يدوياً بالكامل بخلاف المعادلة التلقائية',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty)
                    return 'يرجى تحديد السعر الإجمالي';
                  if (double.tryParse(val) == null) return 'قيمة غير صالحة';
                  return null;
                },
                onChanged: (val) {
                  setState(() {
                    _totalPriceState =
                        double.tryParse(val) ?? (_pricePerNight * _nightsCount);
                  });
                },
              ),
              const SizedBox(height: 12),

              // Deposit amount input
              TextFormField(
                initialValue: _depositAmount.toStringAsFixed(0),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'المبلغ المدفوع كعربون مسبق (0 في حال عدم الدفع)',
                ),
                onChanged: (val) {
                  setState(() {
                    _depositAmount = double.tryParse(val) ?? 0.0;
                  });
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                textAlign: TextAlign.right,
                maxLines: 2,
                decoration:
                    const InputDecoration(labelText: 'أية ملاحظات خاصة بالحجز'),
                onChanged: (val) => _notes = val.trim(),
              ),

              const SizedBox(height: 24),

              // Automatic Invoice estimation
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildCalcRow(
                        'عدد الليلات المحتسبة:', '$_nightsCount ليالٍ'),
                    _buildCalcRow('سعر ليلة السكن:',
                        '${_pricePerNight.toStringAsFixed(0)} د.ج'),
                    const Divider(),
                    _buildCalcRow('إجمالي ثمن الحجز:',
                        '${_totalPriceState.toStringAsFixed(0)} د.ج',
                        isBold: true),
                    _buildCalcRow('العربون المدفوع:',
                        '${_depositAmount.toStringAsFixed(0)} د.ج',
                        color: Colors.green),
                    _buildCalcRow('المتبقي للتسوية عند الاستقبال:',
                        '${_remainingAmount.toStringAsFixed(0)} د.ج',
                        color: Colors.red, isBold: true),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('تراجع وإلغاء'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('حفظ الحجز فوراً'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalcRow(String label, String value,
      {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
              fontSize: 13,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }
}

// Dialog for EDITING a booking
class EditBookingDialog extends ConsumerStatefulWidget {
  final BookingEntity booking;

  const EditBookingDialog({
    super.key,
    required this.booking,
  });

  @override
  ConsumerState<EditBookingDialog> createState() => _EditBookingDialogState();
}

class _EditBookingDialogState extends ConsumerState<EditBookingDialog> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _checkInDate;
  late DateTime _checkOutDate;
  late int _apartmentId;
  late int _guestsCount;
  late double _pricePerNight;
  late double _totalPrice;
  late double _depositAmount;
  late String _notes;

  late TextEditingController _pricePerNightController;
  late TextEditingController _totalPriceController;
  late TextEditingController _nightsCountController;
  late TextEditingController _depositController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _checkInDate = widget.booking.checkInDate;
    _checkOutDate = widget.booking.checkOutDate;
    _apartmentId = widget.booking.apartmentId;
    _guestsCount = widget.booking.guestsCount;
    _pricePerNight = widget.booking.pricePerNight;
    _totalPrice = widget.booking.totalPrice;
    _depositAmount = widget.booking.depositAmount;
    _notes = widget.booking.notes ?? '';

    _pricePerNightController =
        TextEditingController(text: _pricePerNight.toStringAsFixed(0));
    _totalPriceController =
        TextEditingController(text: _totalPrice.toStringAsFixed(0));
    _nightsCountController =
        TextEditingController(text: _nightsCount.toString());
    _depositController =
        TextEditingController(text: _depositAmount.toStringAsFixed(0));
    _notesController = TextEditingController(text: _notes);
  }

  @override
  void dispose() {
    _pricePerNightController.dispose();
    _totalPriceController.dispose();
    _nightsCountController.dispose();
    _depositController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int get _nightsCount {
    final difference = _checkOutDate.difference(_checkInDate).inDays;
    return difference <= 0 ? 1 : difference;
  }

  void _recalculateTotal() {
    setState(() {
      _totalPrice = _pricePerNight * _nightsCount;
      _totalPriceController.text = _totalPrice.toStringAsFixed(0);
      final currentNightsStr = _nightsCount.toString();
      if (_nightsCountController.text != currentNightsStr) {
        _nightsCountController.text = currentNightsStr;
      }
    });
  }

  double get _remainingAmount {
    return (_totalPrice - _depositAmount).clamp(0.0, double.infinity);
  }

  void _onNightsCountChanged(String val) {
    final nights = int.tryParse(val) ?? 1;
    if (nights > 0) {
      setState(() {
        _checkOutDate = _checkInDate.add(Duration(days: nights));
        _recalculateTotal();
      });
    }
  }

  Future<void> _selectCheckInDate() async {
    final chosen = await showDatePicker(
      context: context,
      initialDate: _checkInDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (chosen != null) {
      setState(() {
        _checkInDate = chosen;
        final nights = int.tryParse(_nightsCountController.text) ?? 1;
        _checkOutDate = _checkInDate.add(Duration(days: nights));
        _recalculateTotal();
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    final chosen = await showDatePicker(
      context: context,
      initialDate: _checkOutDate,
      firstDate: _checkInDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (chosen != null) {
      setState(() {
        _checkOutDate = chosen;
        _recalculateTotal();
      });
    }
  }

  Future<void> _saveBooking() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final bookingNotifier = ref.read(bookingsProvider.notifier);

      final updatedBookingModel = BookingModel(
        id: widget.booking.id,
        bookingNumber: widget.booking.bookingNumber,
        guestId: widget.booking.guestId,
        apartmentId: _apartmentId,
        guestsCount: _guestsCount,
        checkInDate: _checkInDate,
        checkOutDate: _checkOutDate,
        actualCheckInDateTime: widget.booking.actualCheckInDateTime,
        actualCheckOutDateTime: widget.booking.actualCheckOutDateTime,
        status: widget.booking.status,
        pricePerNight: _pricePerNight,
        totalPrice: _totalPrice,
        depositAmount: _depositAmount,
        remainingAmount: _remainingAmount,
        notes: _notes,
        createdAt: widget.booking.createdAt,
      );

      await bookingNotifier.updateBooking(updatedBookingModel);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم تعديل بيانات الحجز وبدء المزامنة بنجاح.')),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('تعذر تعديل الحجز', textAlign: TextAlign.right),
          content: Text(e.toString(), textAlign: TextAlign.right),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('حسناً')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final apartmentsList = ref.watch(apartmentsProvider).value ?? [];

    return AlertDialog(
      scrollable: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'تعديل حجز #${widget.booking.bookingNumber}',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Container(
          width: 500,
          constraints: const BoxConstraints(maxWidth: 550),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selection of apartment
              const Text('الشقة المحجوزة *',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              DropdownButtonFormField<int>(
                value: apartmentsList.any((a) => a.id == _apartmentId)
                    ? _apartmentId
                    : null,
                isExpanded: true,
                items: apartmentsList.map((a) {
                  return DropdownMenuItem<int>(
                    value: a.id,
                    child: Text(a.name, textDirection: TextDirection.rtl),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _apartmentId = val;
                    });
                  }
                },
              ),
              const Divider(height: 24),

              // Booking details inputs
              const Text('معلومات السكن والتواريخ:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.indigo)),
              const SizedBox(height: 8),

              // Dates inputs
              Row(
                children: [
                  // Check-Out Date
                  Expanded(
                    child: InkWell(
                      onTap: _selectCheckOutDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'تاريخ المغادرة',
                          labelStyle: TextStyle(fontSize: 12),
                        ),
                        child: Text(
                          intl.DateFormat('yyyy/MM/dd').format(_checkOutDate),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Number of Nights Input
                  Expanded(
                    child: TextFormField(
                      controller: _nightsCountController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        labelText: 'عدد ليالي الإقامة',
                        labelStyle: TextStyle(fontSize: 12),
                      ),
                      onChanged: _onNightsCountChanged,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Check-In Date
                  Expanded(
                    child: InkWell(
                      onTap: _selectCheckInDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'تاريخ الدخول',
                          labelStyle: TextStyle(fontSize: 12),
                        ),
                        child: Text(
                          intl.DateFormat('yyyy/MM/dd').format(_checkInDate),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  // Guests count
                  Expanded(
                    child: TextFormField(
                      initialValue: _guestsCount.toString(),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      decoration:
                          const InputDecoration(labelText: 'عدد الأشخاص'),
                      validator: (val) {
                        if (val != null && val.trim().isNotEmpty) {
                          final parsed = int.tryParse(val);
                          if (parsed == null || parsed <= 0) {
                            return 'يجب أن يكون العدد 1 على الأقل';
                          }
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          _guestsCount = int.tryParse(val) ?? 1;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Customized Price per Night override
                  Expanded(
                    child: TextFormField(
                      controller: _pricePerNightController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                          labelText: 'سعر الليلة (د.ج) *'),
                      validator: (val) {
                        if (val == null || val.isEmpty)
                          return 'يرجى كتابة السعر';
                        if (double.tryParse(val) == null)
                          return 'قيمة غير معتمدة';
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          _pricePerNight = double.tryParse(val) ?? 0.0;
                          _recalculateTotal();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Symmetrical input for Manual OVERRIDE on Total Price
              TextFormField(
                controller: _totalPriceController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'السعر الإجمالي المعتمد للحجز (د.ج) *',
                  helperText:
                      'يمكن تعديل السعر الإجمالي يدوياً بالكامل بخلاف المعادلة التلقائية',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty)
                    return 'يرجى تحديد السعر الإجمالي';
                  if (double.tryParse(val) == null) return 'قيمة غير صالحة';
                  return null;
                },
                onChanged: (val) {
                  setState(() {
                    _totalPrice =
                        double.tryParse(val) ?? (_pricePerNight * _nightsCount);
                  });
                },
              ),
              const SizedBox(height: 12),

              // Deposit amount input
              TextFormField(
                controller: _depositController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'المبلغ المدفوع مقدماً (العربون المسبق) *',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty)
                    return 'يرجى كتابة المبلغ المدفوع مقدماً';
                  if (double.tryParse(val) == null) return 'قيمة غير صالحة';
                  return null;
                },
                onChanged: (val) {
                  setState(() {
                    _depositAmount = double.tryParse(val) ?? 0.0;
                  });
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _notesController,
                textAlign: TextAlign.right,
                maxLines: 2,
                decoration:
                    const InputDecoration(labelText: 'ملاحظات وتفاصيل مهمة'),
                onChanged: (val) => _notes = val.trim(),
              ),

              const SizedBox(height: 24),

              // Automatic Invoice estimation
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildCalcRow(
                        'عدد الليلات المحتسبة:', '$_nightsCount ليالٍ'),
                    _buildCalcRow('سعر ليلة السكن:',
                        '${_pricePerNight.toStringAsFixed(0)} د.ج'),
                    const Divider(),
                    _buildCalcRow('إجمالي ثمن الحجز:',
                        '${_totalPrice.toStringAsFixed(0)} د.ج',
                        isBold: true),
                    _buildCalcRow('المبلغ المدفوع مقدماً:',
                        '${_depositAmount.toStringAsFixed(0)} د.ج',
                        color: Colors.green),
                    _buildCalcRow('المتبقي للتسوية عند الاستقبال:',
                        '${_remainingAmount.toStringAsFixed(0)} د.ج',
                        color: Colors.red, isBold: true),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('تراجع وإلغاء'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('حفظ التعديلات'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalcRow(String label, String value,
      {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
              fontSize: 13,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }
}
