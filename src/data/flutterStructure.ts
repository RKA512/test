export interface FileNode {
  name: string;
  type: 'file' | 'folder';
  description: string;
  code?: string;
  children?: FileNode[];
}

export const flutterFolderStructure: FileNode = {
  name: "rental_app_flutter",
  type: "folder",
  description: "الكود المصدري الأصلي الكامل لمشروع مسير الشقق والكراء الشاغر المكتبي والخلوي.",
  children: [
    {
      name: "pubspec.yaml",
      type: "file",
      description: "حزمة تكوين وإشهار الاعتماديات الأساسية كـ Riverpod و Sqflite ونظام التعريب.",
      code: `name: pms_rental_app
description: An offline-first property management system for receptionist & admin built with Clean Architecture, SQLite, and Riverpod.
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  
  # State Management & DI
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # Database
  sqflite: ^2.3.0
  path: ^1.8.3
  path_provider: ^2.1.1

  # Security & Helpers
  crypto: ^3.0.3
  intl: ^0.19.0
  uuid: ^4.3.3
  file_picker: ^8.0.0

  # Icons Design
  flutter_svg: ^2.0.10.1
  lucide_icons: ^0.320.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^2.3.9
  build_runner: ^2.4.8

flutter:
  uses-material-design: true`
    },
    {
      name: "lib",
      type: "folder",
      description: "صندوق تفاصيل النظام الأساسية مقسمة لطبقات الأمان والكيانات والمتحكمات.",
      children: [
        {
          name: "main.dart",
          type: "file",
          description: "نقطة انطلاق التطبيق وتوجيه واجهات الاستقبال والتعريب.",
          code: `import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Eagerly initialize the local SQLite database
  await DatabaseHelper.instance.database;
  
  runApp(
    const ProviderScope(
      child: PropertyManagerApp(),
    ),
  );
}

class PropertyManagerApp extends StatelessWidget {
  const PropertyManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      ),
      home: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }`
        },
        {
          name: "core",
          type: "folder",
          description: "النواة والمشتركات وقنوات قاعدة البيانات.",
          children: [
            {
              name: "database",
              type: "folder",
              description: "أداة SQLite ddl وهيكلية الجداول وقيود الحذف والخصم المالي والتوافق.",
              children: [
                {
                  name: "database_helper.dart",
                  type: "file",
                  description: "المحرك المحلي لفتح وتحديث وتدقيق حركات قاعدة البيانات.",
                  code: `import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pms_rental.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const integerType = 'INTEGER NOT NULL';
    const integerTypeNullable = 'INTEGER';
    const realType = 'REAL NOT NULL';
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';

    // Users
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        username $textType UNIQUE,
        password_hash $textType,
        full_name $textType,
        role $textType,
        created_at $textType
      )
    ''');

    // Apartments
    await db.execute('''
      CREATE TABLE apartments (
        id $idType,
        name $textType,
        rooms_count $integerType,
        beds_count $integerType,
        max_capacity $integerType,
        base_price $realType,
        notes $textTypeNullable,
        status $textType,
        created_at $textType
      )
    ''');

    // Guests
    await db.execute('''
      CREATE TABLE guests (
        id $idType,
        full_name $textType,
        phone $textType,
        id_card_number $textType,
        nationality $textType,
        notes $textTypeNullable,
        created_at $textType
      )
    ''');

    // Bookings
    await db.execute('''
      CREATE TABLE bookings (
        id $idType,
        booking_number $textType UNIQUE,
        guest_id $integerType,
        apartment_id $integerType,
        guests_count $integerType,
        check_in_date $textType,
        check_out_date $textType,
        actual_checkin_datetime $textTypeNullable,
        actual_checkout_datetime $textTypeNullable,
        status $textType,
        notes $textTypeNullable,
        created_at $textType,
        FOREIGN KEY (guest_id) REFERENCES guests (id) ON DELETE CASCADE,
        FOREIGN KEY (apartment_id) REFERENCES apartments (id) ON DELETE CASCADE
      )
    ''');

    // Payments
    await db.execute('''
      CREATE TABLE payments (
        id $idType,
        booking_id $integerType,
        amount $realType,
        payment_method $textType,
        payment_date $textType,
        notes $textTypeNullable,
        FOREIGN KEY (booking_id) REFERENCES bookings (id) ON DELETE CASCADE
      )
    ''');

    await _seedInitialData(db);
  }
}`
                }
              ]
            },
            {
              name: "error",
              type: "folder",
              description: "إدارة الاستثناءات وأخطاء تداخل المواعيد وصيانة الأخطاء.",
              children: [
                {
                  name: "failures.dart",
                  type: "file",
                  description: "أصناف الفشل المتوقعة للنظام لإظهار الرسائل بشكل عربي منسق.",
                  code: `abstract class Failure {
  final String message;
  const Failure(this.message);
  @override
  String toString() => message;
}
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}
class DoubleBookingFailure extends Failure {
  const DoubleBookingFailure(super.message);
}`
                }
              ]
            }
          ]
        },
        {
          name: "features",
          type: "folder",
          description: "أقسام التطبيق والأنشطة البرمجية.",
          children: [
            {
              name: "auth",
              type: "folder",
              description: "طبقات الحماية، التحقق وصلاحيات الاستقبال والمدير.",
              children: [
                {
                  name: "domain",
                  type: "folder",
                  description: "البنية المجردة للأمن والتحقق.",
                  children: [
                    {
                      name: "user_entity.dart",
                      type: "file",
                      description: "كيان الحساب وصلاحياته الأمنية.",
                      code: `class UserEntity {
  final int? id;
  final String username;
  final String fullName;
  final String role; // 'admin' | 'receptionist'
  final DateTime createdAt;

  const UserEntity({
    this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.createdAt,
  });
}`
                    }
                  ]
                },
                {
                  name: "data",
                  type: "folder",
                  description: "مستودعات معالجة البيانات وتطبيق تشفير كلمة المرور.",
                  children: [
                    {
                      name: "auth_repository_impl.dart",
                      type: "file",
                      description: "تطبيق مستودع الحماية بـ SHA-256 للتحقق والدخول في SQLite.",
                      code: `import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}`
                    }
                  ]
                }
              ]
            },
            {
              name: "bookings",
              type: "folder",
              description: "منظومة تسجيل وتدقيق الحجوزات اليومية.",
              children: [
                {
                  name: "domain",
                  type: "folder",
                  description: "الشروط والتحققات الأساسية للحجوزات.",
                  children: [
                    {
                      name: "booking_entity.dart",
                      type: "file",
                      description: "كيان نموذج الحجز وحساب ليلات المبيت.",
                      code: `enum BookingStatus { confirmed, pendingArrival, checkedIn, completed, cancelled }

class BookingEntity {
  final int? id;
  final String bookingNumber;
  final int guestId;
  final int apartmentId;
  final int guestsCount;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final BookingStatus status;

  const BookingEntity({
    this.id,
    required this.bookingNumber,
    required this.guestId,
    required this.apartmentId,
    required this.guestsCount,
    required this.checkInDate,
    required this.checkOutDate,
    required this.status,
  });
}`
                    }
                  ]
                },
                {
                  name: "data",
                  type: "folder",
                  description: "فحص القيود وحساب تداخل أيام السكن للشقة.",
                  children: [
                    {
                      name: "booking_repository_impl.dart",
                      type: "file",
                      description: "مستودع قاعدة البيانات مع دالة منع تداخل التواريخ لضمان نزاهة الحجوزات.",
                      code: `import '../../../../core/database/database_helper.dart';
import '../../domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<bool> checkOverlappingBooking({
    required int apartmentId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    final db = await _dbHelper.database;
    final inStr = checkIn.toIso8601String().split('T')[0];
    final outStr = checkOut.toIso8601String().split('T')[0];

    final results = await db.rawQuery('''
      SELECT COUNT(*) as count FROM bookings 
      WHERE apartment_id = ? 
        AND status != 'cancelled'
        AND (check_in_date < ? AND check_out_date > ?)
    ''', [apartmentId, outStr, inStr]);
    
    return (results.first['count'] as int? ?? 0) > 0;
  }
}`
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  ]
};
