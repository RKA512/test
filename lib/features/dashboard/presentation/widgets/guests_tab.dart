import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/providers/app_providers.dart';
import '../../../guests/domain/entities/guest_entity.dart';
import '../../../guests/data/models/guest_model.dart';
import '../../../bookings/domain/entities/booking_entity.dart';
import '../../../apartments/domain/entities/apartment_entity.dart';

class GuestsTab extends ConsumerStatefulWidget {
  const GuestsTab({super.key});

  @override
  ConsumerState<GuestsTab> createState() => _GuestsTabState();
}

class _GuestsTabState extends ConsumerState<GuestsTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Controllers for add/edit dialogs
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idCardController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _idCardController.dispose();
    _nationalityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _clearFormControllers() {
    _nameController.clear();
    _phoneController.clear();
    _idCardController.clear();
    _nationalityController.clear();
    _notesController.clear();
  }

  void _setFormControllers(GuestEntity guest) {
    _nameController.text = guest.fullName;
    _phoneController.text = guest.phone;
    _idCardController.text = guest.idCardNumber;
    _nationalityController.text = guest.nationality;
    _notesController.text = guest.notes ?? '';
  }

  // Show dialog to add new guest
  void _showAddGuestDialog() {
    _clearFormControllers();
    _nationalityController.text = 'جزائرية'; // Default

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'تسجيل زبون جديد في النظام',
          textAlign: TextAlign.right,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('الاسم الكامل *',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _nameController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  hintText: 'مثال: محمد الأمين بن علي',
                  hintStyle: TextStyle(fontSize: 12),
                  prefixIcon: Icon(Icons.person, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              const Text('رقم الهاتف *',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.right,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                ],
                decoration: const InputDecoration(
                  hintText: 'مثال: 0661122334',
                  hintStyle: TextStyle(fontSize: 12),
                  prefixIcon: Icon(Icons.phone, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              const Text('رقم بطاقة الهوية / جواز السفر *',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _idCardController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  hintText: 'رقم بطاقة التعريف الوطنية',
                  hintStyle: TextStyle(fontSize: 12),
                  prefixIcon: Icon(Icons.badge, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              const Text('الجنسية *',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _nationalityController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  hintText: 'مثال: جزائرية',
                  hintStyle: TextStyle(fontSize: 12),
                  prefixIcon: Icon(Icons.flag, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              const Text('ملاحظات إضافية عن الزبون',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _notesController,
                textAlign: TextAlign.right,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'ملاحظات حول التدخين، مواعيد المفضلة إلخ...',
                  hintStyle: TextStyle(fontSize: 12),
                  prefixIcon: Icon(Icons.description, size: 18),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nameVal = _nameController.text.trim();
              final phoneVal = _phoneController.text.trim();
              final idCardVal = _idCardController.text.trim();
              final nationalityVal = _nationalityController.text.trim();

              if (nameVal.isEmpty ||
                  phoneVal.isEmpty ||
                  idCardVal.isEmpty ||
                  nationalityVal.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('الرجاء ملء جميع الحقول المطلوبة الكليّة (*)'),
                      backgroundColor: Colors.red),
                );
                return;
              }

              // Validate phone number format (between 8 and 15 digits, starting with optional +)
              if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(phoneVal)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'الرجاء إدخال رقم هاتف صحيح (يتكون من 8 إلى 15 رقماً ودون أحرف)'),
                      backgroundColor: Colors.red),
                );
                return;
              }

              // Verify that identity card / passport number is not duplicated
              final guestsList = ref.read(guestsProvider).value ?? [];
              final isDuplicate = guestsList.any((g) =>
                  g.idCardNumber.trim().toLowerCase() ==
                  idCardVal.toLowerCase());
              if (isDuplicate) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'عذراً، رقم بطاقة الهوية أو جواز السفر هذا مسجّل مسبقاً لزبون آخر في النظام!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final newGuest = GuestModel(
                fullName: nameVal,
                phone: phoneVal,
                idCardNumber: idCardVal,
                nationality: nationalityVal,
                notes: _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
                createdAt: DateTime.now(),
              );

              try {
                await ref.read(guestsProvider.notifier).createGuest(newGuest);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('تم تسجيل الزبون بنجاح'),
                      backgroundColor: Colors.green),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('حدث خطأ أثناء الإضافة: $e'),
                      backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            child: const Text('إضافة الزبون',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Show dialog to edit guest
  void _showEditGuestDialog(GuestEntity guest) {
    _setFormControllers(guest);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'تعديل بيانات: ${guest.fullName}',
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('الاسم الكامل *',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _nameController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              const Text('رقم الهاتف *',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.right,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                ],
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.phone, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              const Text('رقم بطاقة الهوية / جواز السفر *',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _idCardController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.badge, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              const Text('الجنسية *',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _nationalityController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.flag, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              const Text('ملاحظات إضافية عن الزبون',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _notesController,
                textAlign: TextAlign.right,
                maxLines: 2,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.description, size: 18),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nameVal = _nameController.text.trim();
              final phoneVal = _phoneController.text.trim();
              final idCardVal = _idCardController.text.trim();
              final nationalityVal = _nationalityController.text.trim();

              if (nameVal.isEmpty ||
                  phoneVal.isEmpty ||
                  idCardVal.isEmpty ||
                  nationalityVal.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('الرجاء ملء جميع الحقول المطلوبة الكليّة (*)'),
                      backgroundColor: Colors.red),
                );
                return;
              }

              // Validate phone number format (between 8 and 15 digits, starting with optional +)
              if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(phoneVal)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'الرجاء إدخال رقم هاتف صحيح (يتكون من 8 إلى 15 رقماً ودون أحرف)'),
                      backgroundColor: Colors.red),
                );
                return;
              }

              // Verify that identity card / passport number is not duplicated (excluding current guest)
              final guestsList = ref.read(guestsProvider).value ?? [];
              final isDuplicate = guestsList.any((g) =>
                  g.idCardNumber.trim().toLowerCase() ==
                      idCardVal.toLowerCase() &&
                  g.id != guest.id);
              if (isDuplicate) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'عذراً، رقم بطاقة الهوية أو جواز السفر هذا مسجّل مسبقاً لزبون آخر في النظام!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final updatedGuest = GuestModel(
                id: guest.id,
                fullName: nameVal,
                phone: phoneVal,
                idCardNumber: idCardVal,
                nationality: nationalityVal,
                notes: _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
                createdAt: guest.createdAt,
              );

              try {
                await ref
                    .read(guestsProvider.notifier)
                    .updateGuest(updatedGuest);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('تم تعديل بيانات الزبون بنجاح'),
                      backgroundColor: Colors.indigo),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('حدث خطأ أثناء التعديل: $e'),
                      backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            child: const Text('حفظ التغييرات',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Show detailed card for guest
  void _showGuestDetailsCard(GuestEntity guest, List<BookingEntity> bookings,
      List<ApartmentEntity> apartments) {
    final guestBookings = bookings.where((b) => b.guestId == guest.id).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Guest Profile Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.indigo.shade50,
                      child: Text(
                        guest.fullName.isNotEmpty
                            ? guest.fullName[0].toUpperCase()
                            : 'G',
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            color: Colors.indigo),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guest.fullName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'الجنسية: ${guest.nationality}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: Colors.indigo),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Details Grid Details
                const Text(
                  'المعلومات التعريفية:',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: Color(0xFF4F46E5)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(Icons.phone, 'رقم الهاتف:', guest.phone),
                      const Divider(height: 16),
                      _buildDetailRow(Icons.badge_outlined, 'بطاقة الهوية:',
                          guest.idCardNumber),
                      const Divider(height: 16),
                      _buildDetailRow(
                          Icons.calendar_today_outlined,
                          'تاريخ التسجيل:',
                          intl.DateFormat('yyyy/MM/dd - HH:mm')
                              .format(guest.createdAt)),
                      if (guest.notes != null && guest.notes!.isNotEmpty) ...[
                        const Divider(height: 16),
                        _buildDetailRow(Icons.notes, 'ملاحظات:', guest.notes!),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Booking History Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'إجمالي الحجوزات: ${guestBookings.length}',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo),
                      ),
                    ),
                    const Text(
                      'سجل الحجوزات والزيارات للزبون:',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Bookings listing
                if (guestBookings.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: const Center(
                      child: Text(
                        'لم يقم هذا الزبون بأي حجوزات سابقة حتى الآن.',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: guestBookings.length,
                    itemBuilder: (context, index) {
                      final b = guestBookings[index];
                      final apt = apartments.firstWhere(
                        (a) => a.id == b.apartmentId,
                        orElse: () => ApartmentEntity(
                          id: b.apartmentId,
                          name: 'شقة غير متوفرة',
                          roomsCount: 0,
                          bedsCount: 0,
                          maxCapacity: 0,
                          basePrice: 0,
                          status: ApartmentStatus.available,
                          createdAt: DateTime.now(),
                        ),
                      );

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${b.totalPrice.toStringAsFixed(0)} د.ج',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    color: Colors.indigo),
                              ),
                              Text(
                                apt.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    color: Color(0xFF1E293B)),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'رقم الحجز: #${b.bookingNumber}',
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  ),
                                  Text(
                                    'الحالة: ${b.statusArabic}',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            _getBookingStatusColor(b.status)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'الفترة: من ${intl.DateFormat('yyyy/MM/dd').format(b.checkInDate)} إلى ${intl.DateFormat('yyyy/MM/dd').format(b.checkOutDate)} (${b.nightsCount} ليلة)',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBookingStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.blue;
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

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Color(0xFF64748B)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF1E293B)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final guestsAsyncValue = ref.watch(guestsProvider);
    final bookings = ref.watch(bookingsProvider).value ?? [];
    final apartments = ref.watch(apartmentsProvider).value ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'قاعدة بيانات وإدارة الزبائن',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGuestDialog,
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 18),
        label: const Text(
          'إضافة زبون جديد',
          style: TextStyle(
              fontWeight: FontWeight.w900, fontSize: 11, color: Colors.white),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search & Metrics Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Real-time Search TextField
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade100),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: TextField(
                      controller: _searchController,
                      textAlign: TextAlign.right,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim().toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'البحث عن زبون باسمه أو رقم هاتفه...',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                        border: InputBorder.none,
                        icon: const Icon(Icons.search, color: Colors.indigo),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Listing Content
          Expanded(
            child: guestsAsyncValue.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: Colors.indigo)),
              error: (err, stack) => Center(
                child: Text('حدث خطأ في تحميل قائمة النزلاء: $err'),
              ),
              data: (guestsList) {
                // Apply Search Query Matching Name OR Phone Number
                final filteredGuests = guestsList.where((guest) {
                  final nameMatch =
                      guest.fullName.toLowerCase().contains(_searchQuery);
                  final phoneMatch = guest.phone.contains(_searchQuery);
                  return nameMatch || phoneMatch;
                }).toList();

                if (filteredGuests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'لا توجد نتائج مطابقة لعملية البحث وبحثك!'
                              : 'لا يوجد نزلاء مسجلين حالياً في النظام.',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: filteredGuests.length,
                  itemBuilder: (ctx, index) {
                    final guest = filteredGuests[index];

                    // Count total bookings specifically associated with this guest to provide feedback on screen
                    final guestBookingsCount =
                        bookings.where((b) => b.guestId == guest.id).length;

                    return Card(
                      color: Colors.white,
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
                            // Basic Header Information
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.indigo.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'حجوزات: $guestBookingsCount',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            color: Colors.indigo),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        guest.nationality,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            color: Color(0xFF475569)),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      guest.fullName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                          color: Color(0xFF1E293B)),
                                    ),
                                    const SizedBox(width: 10),
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.indigo.shade50,
                                      child: Text(
                                        guest.fullName.isNotEmpty
                                            ? guest.fullName[0].toUpperCase()
                                            : 'G',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: Colors.indigo),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            const SizedBox(height: 12),

                            // Body Info Detail (phone & card ID)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.badge_outlined,
                                        size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      guest.idCardNumber,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF475569)),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      guest.phone,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B)),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.phone_iphone,
                                        size: 14, color: Colors.indigo),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            const SizedBox(height: 12),

                            // Operations & Details Toggle buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Left Side: Action delete with Safety Pre-verification
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('حذف بطاقة العميل',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        content: Text(
                                          'هل أنت متأكد من رغبتك في إزالة العميل "${guest.fullName}" نهائياً من النظام وقاعدة البيانات؟',
                                          textAlign: TextAlign.right,
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: const Text('تراجع')),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            style: TextButton.styleFrom(
                                                foregroundColor: Colors.red),
                                            child:
                                                const Text('نعم، حذف العميل'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      try {
                                        await ref
                                            .read(guestsProvider.notifier)
                                            .deleteGuest(guest.id!);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'تم حذف ملف العميل بنجاح من قاعدة البيانات'),
                                              backgroundColor: Colors.green),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              e
                                                  .toString()
                                                  .replaceAll('Exception: ', '')
                                                  .replaceAll(
                                                      'DatabaseFailure:', ''),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red, size: 14),
                                  label: const Text('إزالة',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Color(0xFFFFECEC)),
                                    backgroundColor: const Color(0xFFFFF8F8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                  ),
                                ),

                                // Right Side: Details Cards & Edit Dialog Button triggers
                                Row(
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          _showEditGuestDialog(guest),
                                      icon: const Icon(Icons.edit_outlined,
                                          size: 14),
                                      label: const Text('تعديل',
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.indigo,
                                        side: BorderSide(
                                            color: Colors.indigo.shade100),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () => _showGuestDetailsCard(
                                          guest, bookings, apartments),
                                      icon: const Icon(
                                          Icons.assignment_ind_outlined,
                                          size: 14,
                                          color: Colors.white),
                                      label: const Text('البطاقة الكاملة',
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.indigo,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
