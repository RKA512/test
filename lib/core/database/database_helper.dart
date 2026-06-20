import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static int? activeUserId;

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
      version: 2,
      onConfigure: _onConfigure,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration to Version 2: Adding 'apartment_id' column to 'expenses' if upgrading from version 1
      try {
        await db.execute('ALTER TABLE expenses ADD COLUMN apartment_id INTEGER NULL REFERENCES apartments(id) ON DELETE SET NULL');
      } catch (e) {
        // Suppress error if the column already exists (safely handle schema drift)
      }
    }
  }

  Future<void> _createDB(Database db, int version) async {
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const integerType = 'INTEGER NOT NULL';
    const integerTypeNullable = 'INTEGER';
    const realType = 'REAL NOT NULL';
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';

    // 1. Users Table
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

    // 2. Apartments Table
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

    // 3. Guests Table
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

    // 4. Bookings Table
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
        price_per_night $realType,
        total_price $realType,
        deposit_amount $realType,
        remaining_amount $realType,
        notes $textTypeNullable,
        created_at $textType,
        FOREIGN KEY (guest_id) REFERENCES guests (id) ON DELETE CASCADE,
        FOREIGN KEY (apartment_id) REFERENCES apartments (id) ON DELETE CASCADE
      )
    ''');

    // 5. Payments Table (Keep database normalized, booking stores no paid amount)
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

    // 6. Expenses Table
    await db.execute('''
      CREATE TABLE expenses (
        id $idType,
        apartment_id $integerTypeNullable,
        amount $realType,
        expense_type $textType,
        description $textType,
        expense_date $textType,
        created_by $integerType,
        FOREIGN KEY (apartment_id) REFERENCES apartments (id) ON DELETE SET NULL,
        FOREIGN KEY (created_by) REFERENCES users (id)
      )
    ''');

    // 7. Backups Table
    await db.execute('''
      CREATE TABLE backups (
        id $idType,
        file_name $textType,
        file_path $textType,
        created_at $textType,
        backup_size $textType,
        created_by $integerType,
        FOREIGN KEY (created_by) REFERENCES users (id)
      )
    ''');

    // 8. Audit Logs Table
    await db.execute('''
      CREATE TABLE audit_logs (
        id $idType,
        user_id $integerTypeNullable,
        action $textType,
        entity_type $textType,
        entity_id $integerTypeNullable,
        created_at $textType,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL
      )
    ''');

    // Seed default users (Admin + Receptionist) to allow secure logins from startup
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    final now = DateTime.now().toIso8601String();
    
    // Hash standard starting passwords safely
    final adminHash = sha256.convert(utf8.encode('admin123')).toString();

    await db.insert('users', {
      'username': 'admin',
      'password_hash': adminHash,
      'full_name': 'المدير العام للمنظومة',
      'role': 'admin',
      'created_at': now,
    });
  }

  // Unified Audit Logging helper
  Future<int> insertAuditLog({
    required int? userId,
    required String action,
    required String entityType,
    required int? entityId,
  }) async {
    final db = await instance.database;
    final finalUserId = userId ?? DatabaseHelper.activeUserId;
    return await db.insert('audit_logs', {
      'user_id': finalUserId,
      'action': action,
      'entity_type': entityType,
      'entity_id': entityId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
