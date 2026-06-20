import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/providers/app_providers.dart';
import '../../../expenses/data/models/expense_model.dart';
import '../../../apartments/domain/entities/apartment_entity.dart';

class ExpensesTab extends ConsumerStatefulWidget {
  const ExpensesTab({super.key});

  @override
  ConsumerState<ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends ConsumerState<ExpensesTab> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'general';
  int? _selectedApartmentId;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAddExpenseDialog() {
    _amountController.clear();
    _descriptionController.clear();
    _selectedCategory = 'general';
    _selectedApartmentId = null;

    showDialog(
      context: context,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final apartments = ref.watch(apartmentsProvider).value ?? [];

          return AlertDialog(
            title: const Text('تسجيل مصروف أو نفقة مالية جديدة',
                textAlign: TextAlign.right,
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('قيمة التكلفة للمصروف (د.ج) *',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(hintText: 'مثال: 4500'),
                  ),
                  const SizedBox(height: 12),
                  const Text('تصنيف المصروف الأساسي',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    alignment: AlignmentDirectional.centerEnd,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCategory = val;
                        });
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                          value: 'general',
                          child: Text('مصاريف عامة متنوعة',
                              textAlign: TextAlign.right)),
                      DropdownMenuItem(
                          value: 'cleaning',
                          child: Text('مواد ومصاريف تنظيف الشقق',
                              textAlign: TextAlign.right)),
                      DropdownMenuItem(
                          value: 'repairs',
                          child: Text('تصليحات سباكة، كهرباء، وصيانة',
                              textAlign: TextAlign.right)),
                      DropdownMenuItem(
                          value: 'utilities',
                          child: Text('فواتير ماء، كهرباء، إنترنت مخصص',
                              textAlign: TextAlign.right)),
                      DropdownMenuItem(
                          value: 'laundry',
                          child: Text('مصاريف غسيل وكي الشراشف والوسادات',
                              textAlign: TextAlign.right)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('تحميل المصروف لشقة معينة (اختياري)',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<int?>(
                    value: _selectedApartmentId,
                    isExpanded: true,
                    alignment: AlignmentDirectional.centerEnd,
                    hint: const Text('حساب عام للمؤسسة بأكملها',
                        textAlign: TextAlign.right),
                    onChanged: (val) {
                      setState(() {
                        _selectedApartmentId = val;
                      });
                    },
                    items: [
                      const DropdownMenuItem(
                          value: null,
                          child: Text('حساب عام للمؤسسة بأكملها',
                              textAlign: TextAlign.right)),
                      ...apartments.map((apt) {
                        return DropdownMenuItem(
                            value: apt.id,
                            child: Text(apt.name, textAlign: TextAlign.right));
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('تفاصيل ومبرر النفقة *',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    controller: _descriptionController,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    decoration: const InputDecoration(
                        hintText:
                            'مثال: شراء ملمع زجاج وعطور لتهيئة شقة رقم F3'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () async {
                  final amt = double.tryParse(_amountController.text) ?? 0.0;
                  final desc = _descriptionController.text.trim();
                  if (amt <= 0 || desc.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'يرجى كتابة المبرر وتحديد قيادة مالية صحيحة.')),
                    );
                    return;
                  }

                  final currentUser = ref.read(authProvider).currentUser;

                  final payload = ExpenseModel(
                    amount: amt,
                    expenseType: _selectedCategory,
                    description: desc,
                    apartmentId: _selectedApartmentId,
                    expenseDate: DateTime.now(),
                    createdBy: currentUser?.id ?? 1,
                  );

                  await ref
                      .read(expensesProvider.notifier)
                      .createExpense(payload);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white),
                child: const Text('تسجيل بالدفتر'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);
    final apartments = ref.watch(apartmentsProvider).value ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('دفتر تسيير المصاريف والنفقات الجانبية'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ElevatedButton.icon(
              onPressed: _showAddExpenseDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('تسجيل مصروف جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Total Sum Metric Bar
          expensesAsync.maybeWhen(
            orElse: () => const SizedBox(),
            data: (list) {
              final total = list.fold<double>(0.0,
                  (previousValue, element) => previousValue + element.amount);
              return Container(
                color: Colors.red.shade50,
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${total.toStringAsFixed(0)} د.ج',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.red.shade900,
                          fontSize: 16),
                    ),
                    Row(
                      children: [
                        Text(
                          'إجمالي النفقات والمصاريف المسجلة حالياً (${list.length}):',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade900,
                              fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.info_outline,
                            size: 16, color: Colors.red),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // Main list View
          Expanded(
            child: expensesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) =>
                  Center(child: Text('خطأ في تحميل الدفتر: $err')),
              data: (list) {
                if (list.isEmpty) {
                  return const Center(
                    child: Text(
                        'سجل المصاريف فارغ حالياً. ممتاز! لا توجد تكاليف زائدة.'),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final exp = list[index];

                    // Find linked apartment name if any
                    String aptLabel = 'مصروف عام للمؤسسة';
                    if (exp.apartmentId != null) {
                      final targetApt = apartments.firstWhere(
                        (a) => a.id == exp.apartmentId,
                        orElse: () => ApartmentEntity(
                          id: 0,
                          name: '',
                          roomsCount: 0,
                          bedsCount: 0,
                          maxCapacity: 0,
                          basePrice: 0,
                          status: ApartmentStatus.available,
                          createdAt: DateTime(2026),
                        ),
                      );
                      if (targetApt.name.isNotEmpty) {
                        aptLabel = 'مخصص لـ: ${targetApt.name}';
                      }
                    }

                    return Card(
                      color: Colors.white,
                      elevation: 0.1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.receipt_long,
                              color: Colors.blueGrey),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${exp.amount.toStringAsFixed(0)} د.ج',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.red,
                                  fontSize: 14),
                            ),
                            Text(
                              exp.expenseTypeArabic,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF1E293B)),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 4),
                            Text(exp.description,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF334155))),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  intl.DateFormat('yyyy/MM/dd')
                                      .format(exp.expenseDate),
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                ),
                                Text(
                                  aptLabel,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent, size: 20),
                          tooltip: 'حذف المصروف',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('تأكيد الحذف',
                                    textAlign: TextAlign.right),
                                content: const Text(
                                    'هل أنت متأكد من حذف هذه النفقة نهائياً من الدفتر؟',
                                    textAlign: TextAlign.right),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('تراجع')),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.red),
                                    child: const Text('حذف الآن'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await ref
                                  .read(expensesProvider.notifier)
                                  .deleteExpense(exp.id!);
                            }
                          },
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
