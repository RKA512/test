import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../database/database_helper.dart';

class BackupService {
  static final BackupService instance = BackupService._init();
  BackupService._init();

  // Get path where backups are stored locally
  Future<Directory> getBackupDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(join(docsDir.path, 'pms_backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  // Perform a full real manual backup of the SQLite database file
  Future<File> createBackup({required int userId, String? customName}) async {
    try {
      final db = await DatabaseHelper.instance.database;
      
      // Flush database buffers cleanly to ensure no corrupted files are copied
      await db.rawQuery('PRAGMA wal_checkpoint(FULL);');

      final dbPath = await getApplicationDocumentsDirectory();
      final sourceFile = File(join(dbPath.path, 'pms_rental.db'));

      if (!await sourceFile.exists()) {
        throw Exception('ملف قاعدة البيانات الأصلي غير موجود.');
      }

      final backupFolder = await getBackupDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = customName ?? 'backup_$timestamp.db';
      final targetFile = File(join(backupFolder.path, fileName));

      // Real SQLite file copy
      final copiedFile = await sourceFile.copy(targetFile.path);

      // Record backup metadata in database
      final sizeInBytes = await copiedFile.length();
      final sizeKb = (sizeInBytes / 1024).toStringAsFixed(2) + ' KB';

      await db.insert('backups', {
        'file_name': fileName,
        'file_path': targetFile.path,
        'created_at': DateTime.now().toIso8601String(),
        'backup_size': sizeKb,
        'created_by': userId,
      });

      await DatabaseHelper.instance.insertAuditLog(
        userId: userId,
        action: 'إنشاء نسخة احتياطية محلية باسم: $fileName',
        entityType: 'backups',
        entityId: null,
      );

      return copiedFile;
    } catch (e) {
      throw Exception('فشل إنشاء النسخة الاحتياطية الموضعية لقاعدة البيانات: $e');
    }
  }

  // Restore the database from a backup file
  Future<void> restoreBackup(String backupFilePath, {int? userId}) async {
    try {
      // First, close current DB connection cleanly
      await DatabaseHelper.instance.close();

      final dbPath = await getApplicationDocumentsDirectory();
      final targetDbFile = File(join(dbPath.path, 'pms_rental.db'));
      final sourceBackupFile = File(backupFilePath);

      if (!await sourceBackupFile.exists()) {
        throw Exception('ملف النسخة الاحتياطية المحدد غير موجود.');
      }

      // Overwrite current database file with the backup
      await sourceBackupFile.copy(targetDbFile.path);

      // Force-reopen the database to verify success and log audit
      final db = await DatabaseHelper.instance.database;
      
      await DatabaseHelper.instance.insertAuditLog(
        userId: userId,
        action: 'استرجاع ناجح لقاعدة البيانات من ملف خارجي',
        entityType: 'backups',
        entityId: null,
      );
    } catch (e) {
      throw Exception('فشل استعادة قاعدة البيانات من النسخة المحددة: $e');
    }
  }

  // Fetch all historic backups stored in database
  Future<List<Map<String, dynamic>>> fetchBackupHistory() async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.query('backups', orderBy: 'created_at DESC');
    } catch (e) {
      return [];
    }
  }

  // Delete backup
  Future<void> deleteBackup(int id, String filePath, {required int adminUserId}) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete('backups', where: 'id = ?', whereArgs: [id]);
      
      // Delete from physical storage
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      await DatabaseHelper.instance.insertAuditLog(
        userId: adminUserId,
        action: 'حذف ملف نسخة احتياطية من القرص',
        entityType: 'backups',
        entityId: id,
      );
    } catch (e) {
      throw Exception('فشل حذف ملف النسخة الاحتياطية: $e');
    }
  }
}
