import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../apartments/domain/entities/apartment_entity.dart';
import '../../../apartments/data/models/apartment_model.dart';
import 'booking_dialogs.dart';

class ApartmentsTab extends ConsumerStatefulWidget {
  const ApartmentsTab({super.key});

  @override
  ConsumerState<ApartmentsTab> createState() => _ApartmentsTabState();
}

class _ApartmentsTabState extends ConsumerState<ApartmentsTab> {
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _roomsController = TextEditingController();
  final _bedsController = TextEditingController();
  final _capacityController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _roomsController.dispose();
    _bedsController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _clearAptForm() {
    _nameController.clear();
    _roomsController.clear();
    _bedsController.clear();
    _capacityController.clear();
    _priceController.clear();
    _notesController.clear();
  }

  // Double trigger to quickly create or edit apartment
  Future<void> _showApartmentForm({ApartmentEntity? existingApt}) async {
    final isAdmin = ref.read(authProvider).currentUser?.isAdmin ?? false;
    if (!isAdmin) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('غير مسموح له بالوصول', textAlign: TextAlign.right),
          content: const Text(
              'عذراً، يجب تسجيل الدخول كمدير للنظام لإضافة أو تعديل الشقق الفندقية.',
              textAlign: TextAlign.right),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('حسناً')),
          ],
        ),
      );
      return;
    }

    if (existingApt != null) {
      _nameController.text = existingApt.name;
      _roomsController.text = existingApt.roomsCount.toString();
      _bedsController.text = existingApt.bedsCount.toString();
      _capacityController.text = existingApt.maxCapacity.toString();
      _priceController.text = existingApt.basePrice.toStringAsFixed(0);
      _notesController.text = existingApt.notes ?? '';
    } else {
      _clearAptForm();
    }

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        title: Text(
          existingApt != null
              ? 'تعديل بيانات الشقة ريادياً'
              : 'إضافة شقة فندقية جديدة',
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                    labelText: 'اسم الشقة الفندقية المميز *'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _bedsController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                          labelText: 'عدد الأسرة المتاحة *'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _roomsController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                          labelText: 'عدد الغرف الفعلي *'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                          labelText: 'السعر الافتراضي لليلة (د.ج) *'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _capacityController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                          labelText: 'الأشخاص الأقصى الموصى بهم'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                textAlign: TextAlign.right,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'ملاحظة عامة عن التجهيز أو الحالة اللوجستية'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء التعديل'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _nameController.text.trim();
              final rooms = int.tryParse(_roomsController.text) ?? 1;
              final beds = int.tryParse(_bedsController.text) ?? 1;
              final cap = int.tryParse(_capacityController.text) ?? 1;
              final price = double.tryParse(_priceController.text) ?? 0.0;
              final notes = _notesController.text.trim();

              if (name.isEmpty || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'يرجى التأكد من ملء جميع الحقول ووضع ثمن لليلة.')),
                );
                return;
              }

              final payload = ApartmentModel(
                id: existingApt?.id,
                name: name,
                roomsCount: rooms,
                bedsCount: beds,
                maxCapacity: cap,
                basePrice: price,
                notes: notes,
                status: existingApt?.status ?? ApartmentStatus.available,
                createdAt: existingApt?.createdAt ?? DateTime.now(),
              );

              final notifier = ref.read(apartmentsProvider.notifier);
              if (existingApt != null) {
                await notifier.updateApartment(payload);
              } else {
                await notifier.createApartment(payload);
              }

              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white),
            child: const Text('حفظ التغييرات'),
          ),
        ],
      ),
    );
  }

  Color _getStatusBg(ApartmentStatus status) {
    switch (status) {
      case ApartmentStatus.available:
        return const Color(0xFFD1FAE5);
      case ApartmentStatus.occupied:
        return const Color(0xFFFEE2E2);
      case ApartmentStatus.cleaning:
        return const Color(0xFFFEF3C7);
      case ApartmentStatus.maintenance:
        return const Color(0xFFE2E8F0);
    }
  }

  Color _getStatusText(ApartmentStatus status) {
    switch (status) {
      case ApartmentStatus.available:
        return const Color(0xFF065F46);
      case ApartmentStatus.occupied:
        return const Color(0xFF991B1B);
      case ApartmentStatus.cleaning:
        return const Color(0xFF92400E);
      case ApartmentStatus.maintenance:
        return const Color(0xFF1E293B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final user = ref.read(authProvider).currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الشقق والفندقية المتاحة لتسيير الكراء والمقامات'),
        actions: [
          if (user?.isAdmin == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ElevatedButton.icon(
                onPressed: () => _showApartmentForm(),
                icon: const Icon(Icons.add_business_rounded, size: 18),
                label: const Text('إضافة شقة فندقية جديدة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filters Header Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _searchController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'البحث عن الشقة بواسطة الاسم أو التجهيز...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Main list container
          Expanded(
            child: apartmentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('فشل تحميل القائمة: $err')),
              data: (list) {
                final query = _searchController.text.trim().toLowerCase();
                final filtered = list.where((apt) {
                  return apt.name.toLowerCase().contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'لا توجد شقق مطابقة لبحثك تالياً.',
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                  );
                }

                return GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    mainAxisExtent: 220,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final apt = filtered[index];

                    return Card(
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Title & status indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusBg(apt.status),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    apt.statusArabic,
                                    style: TextStyle(
                                      color: _getStatusText(apt.status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    apt.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Rooms / Beds / Capacity counters row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _buildIconSpec(
                                    Icons.people, '${apt.maxCapacity} نزلاء'),
                                const SizedBox(width: 12),
                                _buildIconSpec(
                                    Icons.king_bed, '${apt.bedsCount} أسرة'),
                                const SizedBox(width: 12),
                                _buildIconSpec(Icons.meeting_room,
                                    '${apt.roomsCount} غرف'),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Pricing default hint
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${apt.basePrice.toStringAsFixed(0)} د.ج / ليلة السكن',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.indigo,
                                      fontSize: 13),
                                ),
                                const Text('السعر المرجعي الافتراضي:',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.blueGrey)),
                              ],
                            ),

                            const Spacer(),

                            // Dynamic Quick Actions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Action Menu options (Edit/Delete status)
                                PopupMenuButton<String>(
                                  onSelected: (action) async {
                                    if (action == 'edit') {
                                      _showApartmentForm(existingApt: apt);
                                    } else if (action == 'delete') {
                                      final adminId = ref
                                          .read(authProvider)
                                          .currentUser
                                          ?.id;
                                      if (adminId != null) {
                                        await ref
                                            .read(apartmentsProvider.notifier)
                                            .deleteApartment(apt.id!, adminId);
                                      }
                                    } else {
                                      // Status updates
                                      ApartmentStatus targetStatus =
                                          ApartmentStatus.available;
                                      if (action == 'status_cleaning')
                                        targetStatus = ApartmentStatus.cleaning;
                                      if (action == 'status_maint')
                                        targetStatus =
                                            ApartmentStatus.maintenance;
                                      if (action == 'status_avail')
                                        targetStatus =
                                            ApartmentStatus.available;
                                      await ref
                                          .read(apartmentsProvider.notifier)
                                          .changeStatus(apt.id!, targetStatus);
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(
                                        value: 'status_avail',
                                        child: Text('تحويل لشاغرة (جاهزة)',
                                            textAlign: TextAlign.right)),
                                    const PopupMenuItem(
                                        value: 'status_cleaning',
                                        child: Text(
                                            'تحويل لـ قيد التنظيف والتهيئة',
                                            textAlign: TextAlign.right)),
                                    const PopupMenuItem(
                                        value: 'status_maint',
                                        child: Text(
                                            'تحويل لـ تحت أعمال الصيانة',
                                            textAlign: TextAlign.right)),
                                    if (user?.isAdmin == true) ...[
                                      const PopupMenuDivider(),
                                      const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('تعديل خصائص الشقة',
                                              textAlign: TextAlign.right)),
                                      const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('حذف الشقة نهائياً',
                                              style:
                                                  TextStyle(color: Colors.red),
                                              textAlign: TextAlign.right)),
                                    ]
                                  ],
                                  child: const Text('تحرير الحالة ⚙️',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.indigo,
                                          fontWeight: FontWeight.bold)),
                                ),

                                // Direct Quick booking button
                                ElevatedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          CreateBookingDialog(apartment: apt),
                                    );
                                  },
                                  icon: const Icon(Icons.add_circle, size: 14),
                                  label: const Text('حجز فوري سريع',
                                      style: TextStyle(fontSize: 11)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
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

  Widget _buildIconSpec(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text,
            style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
        const SizedBox(width: 4),
        Icon(icon, size: 14, color: Colors.grey),
      ],
    );
  }
}
