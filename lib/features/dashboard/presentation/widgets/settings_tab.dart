import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/backup_service.dart';

class SettingsTab extends ConsumerStatefulWidget {
  const SettingsTab({super.key});

  @override
  ConsumerState<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<SettingsTab> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  final _newUsernameController = TextEditingController();
  final _newStaffPasswordController = TextEditingController();
  final _newStaffFullNameController = TextEditingController();
  String _newStaffRole = 'receptionist';

  List<Map<String, dynamic>> _backupHistory = [];
  bool _isLoadingBackups = true;

  @override
  void initState() {
    super.initState();
    _loadBackupList();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _newUsernameController.dispose();
    _newStaffPasswordController.dispose();
    _newStaffFullNameController.dispose();
    super.dispose();
  }

  Future<void> _loadBackupList() async {
    setState(() => _isLoadingBackups = true);
    final history = await BackupService.instance.fetchBackupHistory();
    setState(() {
      _backupHistory = history;
      _isLoadingBackups = false;
    });
  }

  Future<void> _handleCreateBackup() async {
    final currentUser = ref.read(authProvider).currentUser;
    if (currentUser?.id == null) return;

    try {
      await BackupService.instance.createBackup(userId: currentUser!.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'تم إنشاء نسخة احتياطية محلية لقاعدة البيانات بنظام آمن.')),
      );
      _loadBackupList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء تشكيل النسخة الاحتياطية: $e')),
      );
    }
  }

  Future<void> _handleRestoreBackup(String filePath) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد استرجاع البيانات', textAlign: TextAlign.right),
        content: const Text(
          'تنبيه: سيتم استرجاع السجلات القديمة واستبدال قاعدة البيانات الفورية بملف الاسترداد. هل ترغب بالاستمرار؟',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('تأكيد الاسترجاع والتشغيل الفوري'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final currentUser = ref.read(authProvider).currentUser;
        await BackupService.instance
            .restoreBackup(filePath, userId: currentUser?.id);

        // Force refresh all providers to reload values from restored SQLite database file
        ref.read(apartmentsProvider.notifier).loadApartments();
        ref.read(bookingsProvider.notifier).loadBookings();
        ref.read(expensesProvider.notifier).loadExpenses();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'تم استعادة البيانات بنجاح من الملف وجاري تحديث السجلات.')),
        );
        _loadBackupList();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشلت محاولة الاسترجاع: $e')),
        );
      }
    }
  }

  Future<void> _handleDeleteBackup(int id, String filePath) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف ملف الحفظ', textAlign: TextAlign.right),
        content: const Text(
            'هل تريد إزالة ملف هذه النسخة الاحتياطية نهائياً من القرص؟',
            textAlign: TextAlign.right),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('تراجع')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف نهائياً'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final currentUser = ref.read(authProvider).currentUser;
      if (currentUser?.id == null) return;

      await BackupService.instance
          .deleteBackup(id, filePath, adminUserId: currentUser!.id!);
      _loadBackupList();
    }
  }

  Future<void> _handleChangePassword() async {
    final oldPass = _oldPasswordController.text;
    final newPass = _newPasswordController.text;

    if (oldPass.isEmpty || newPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء كافة حقول كلمة المرور.')),
      );
      return;
    }

    try {
      await ref.read(authProvider.notifier).changePassword(oldPass, newPass);
      _oldPasswordController.clear();
      _newPasswordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث كلمة المرور الخاصة بك بنجاح.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل التعديل: كلمة المرور الحالية غير صحيحة.')),
      );
    }
  }

  Future<void> _handleAddNewStaff() async {
    final username = _newUsernameController.text.trim();
    final password = _newStaffPasswordController.text;
    final fullName = _newStaffFullNameController.text.trim();

    if (username.isEmpty || password.isEmpty || fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('يرجى تعبئة كافة الحقول الخاصة بالموظف الجديد.')),
      );
      return;
    }

    try {
      await ref
          .read(authProvider.notifier)
          .createUser(username, password, fullName, _newStaffRole);

      _newUsernameController.clear();
      _newStaffPasswordController.clear();
      _newStaffFullNameController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('تم إضافة ملف الموظف الجديد بنجاح في سجلات النظام.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('فشل الإضافة: قد يكون اسم المستخدم مكرر بالفعل.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authProvider).currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الإدارة والنسخ الاحتياطي وحماية الحسابات'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Row layout for settings sections
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                // 1. Backups Panel
                Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _handleCreateBackup,
                            icon: const Icon(Icons.backup_rounded, size: 16),
                            label: const Text('نسخ احتياطي فوري'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const Text(
                            'النسخ الاحتياطي والأمن الخارجي',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'النظام يدعم الأرشفة اليدوية الكاملة للملفات بصيغة SQLite وتصديرها لجهة الحماية، ومحضر مسبقاً للمزامنة السحابية مستقبلاً.',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 11, color: Colors.blueGrey, height: 1.5),
                      ),
                      const Divider(height: 24),
                      const Text(
                        'قائمة الحفظ والأرشيفات المتوفرة:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 12),
                      if (_isLoadingBackups)
                        const Center(child: CircularProgressIndicator())
                      else if (_backupHistory.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                              child: Text('سجل النسخ الاحتياطية فارغ.',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey))),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _backupHistory.length,
                          separatorBuilder: (ctx, idx) =>
                              const Divider(height: 1),
                          itemBuilder: (ctx, idx) {
                            final b = _backupHistory[idx];
                            return ListTile(
                              title: Text(b['file_name'] as String,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                'تاريخ الحفظ: ${intl.DateFormat('yyyy/MM/dd HH:mm').format(DateTime.parse(b['created_at'] as String))} | الحجم: ${b['backup_size']}',
                                style: const TextStyle(fontSize: 9),
                              ),
                              leading: IconButton(
                                icon: const Icon(Icons.restore_page_rounded,
                                    color: Colors.indigo, size: 20),
                                tooltip: 'استعادة قاعدة البيانات للأصل',
                                onPressed: () => _handleRestoreBackup(
                                    b['file_path'] as String),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent, size: 18),
                                onPressed: () => _handleDeleteBackup(
                                    b['id'] as int, b['file_path'] as String),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),

                // 2. Security Change Password Card
                Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'تحديث كلمة مرورك لحماية مبيتك',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 14),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _oldPasswordController,
                        obscureText: true,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                            labelText: 'قفل المرور القديم لتوثيق الهوية'),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: true,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                            labelText: 'قفل المرور الجديد المقترح للمستقبل'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _handleChangePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('تأكيد تعديل الرمز السري'),
                      ),
                    ],
                  ),
                ),

                // 3. Admin Account Creation (Only for role: Admin)
                if (user?.isAdmin == true)
                  Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'تسجيل موظف جديد بالنظام',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 14),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _newStaffFullNameController,
                          textAlign: TextAlign.right,
                          decoration: const InputDecoration(
                              labelText: 'اسم الموظف الكامل للتعريف'),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _newUsernameController,
                          textAlign: TextAlign.right,
                          decoration: const InputDecoration(
                              labelText: 'اسم المستخدم اللاتيني للدخول'),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _newStaffPasswordController,
                          obscureText: true,
                          textAlign: TextAlign.right,
                          decoration: const InputDecoration(
                              labelText:
                                  'كلمة مرور الدخول الأولية لتوظيف الحساب'),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _newStaffRole,
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _newStaffRole = val);
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                                value: 'receptionist',
                                child: Text('موظف استقبال (صلاحيات محدودة)',
                                    textAlign: TextAlign.right)),
                            DropdownMenuItem(
                                value: 'admin',
                                child: Text('مدير نظام كامل (صلاحيات كاملة)',
                                    textAlign: TextAlign.right)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _handleAddNewStaff,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('تسجيل ملف الموظف والتوظيف'),
                        ),
                      ],
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
