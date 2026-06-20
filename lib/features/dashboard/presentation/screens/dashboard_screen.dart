import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../widgets/apartments_tab.dart';
import '../widgets/calendar_tab.dart';
import '../widgets/guests_tab.dart';
import '../widgets/payments_tab.dart';
import '../widgets/expenses_tab.dart';
import '../widgets/reports_tab.dart';
import '../widgets/settings_tab.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  // List of Tabs constructed dynamically
  final List<Widget> _tabs = const [
    ApartmentsTab(),
    CalendarTab(),
    GuestsTab(),
    PaymentsTab(),
    ExpensesTab(),
    ReportsTab(),
    SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).currentUser;

    return Directionality(
      textDirection: TextDirection.rtl, // Globally enforce RTL
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),

        // Main App bar for Global State (logout / username display)
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: false,
          leading: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.apartment_rounded,
                color: Color(0xFF4F46E5), size: 32),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'مسير الحجوزات والشقق الفندقية',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 1),
              Text(
                'مرحباً بك: ${user?.fullName ?? ""} (${user?.roleArabic ?? ""})',
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            // Logout button
            OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title:
                        const Text('تسجيل الخروج', textAlign: TextAlign.right),
                    content: const Text(
                        'هل أنت متأكد من رغبتك في الخروج الآمن من النظام وإقفال الجلسة الفورية؟',
                        textAlign: TextAlign.right),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('تراجع')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('خروج آمن'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  ref.read(authProvider.notifier).logout();
                }
              },
              icon: const Icon(Icons.lock_open_rounded, size: 14),
              label: const Text('خروج من النظام'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Color(0xFFFFECEC)),
                backgroundColor: const Color(0xFFFFF8F8),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),

        // Body content representing the selected Tab layout
        body: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),

        // Beautiful bottom navigation explicitly optimized for easy touch target visibility and Arabic labelling.
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
                top: BorderSide(color: Colors.grey.shade100, width: 0.5)),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF4F46E5),
            unselectedItemColor: const Color(0xFF64748B),
            selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 11,
                fontFamily: 'Tajawal'),
            unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                fontFamily: 'Tajawal'),
            iconSize: 22,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_work_outlined),
                activeIcon: Icon(Icons.home_work_rounded),
                label: 'الشقق الفندقية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined),
                activeIcon: Icon(Icons.calendar_month_rounded),
                label: 'مخطط الحجوزات',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people_rounded),
                label: 'إدارة الزبائن',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.payments_outlined),
                activeIcon: Icon(Icons.payments_rounded),
                label: 'المدفوعات والتحصيل',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long_rounded),
                label: 'المصاريف والنفقات',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined),
                activeIcon: Icon(Icons.analytics_rounded),
                label: 'تقارير الأداء',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shield_outlined),
                activeIcon: Icon(Icons.shield_rounded),
                label: 'الأمن والإدارة',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
