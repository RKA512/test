import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/database/database_helper.dart';
import 'core/providers/app_providers.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Eagerly initialize the local SQLite database
  await DatabaseHelper.instance.database;

  runApp(
    const ProviderScope(
      child: PropertyManagerApp(),
    ),
  );
}

class PropertyManagerApp extends ConsumerWidget {
  const PropertyManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Property Manager App',
      debugShowCheckedModeBanner: false,

      // Ensure the system supports native Arabic locale
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'DZ'), // Arabic (Algeria)
      ],
      locale: const Locale('ar', 'DZ'),

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Tajawal',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5), // Indigo primary
          primary: const Color(0xFF4F46E5),
          secondary: const Color(0xFF0F172A), // Slate secondary
          surface: const Color(0xFFF8FAFC),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 1,
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        ),
      ),

      // Dynamic routing based on authenticated user state
      home: authState.currentUser != null
          ? const DashboardScreen()
          : const LoginScreen(),
    );
  }
}
