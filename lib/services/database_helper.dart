import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'stock_database.db');

    return await openDatabase(
      path,
      version: 3, // Augmente la version pour appliquer la migration
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE stocks("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "supplier TEXT,"
          "date TEXT,"
          "quantity_received INTEGER,"
          "quantity_received_type TEXT,"
          "sorted_quantity REAL,"
          "exact_quantity REAL,"
          "unit_price INTEGER,"
          "unit_price_type TEXT,"
          "amount REAL,"
          "paid_amount REAL,"
          "remaining_amount REAL,"
          "date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
          ")",
        );

        await db.execute(
          "CREATE TABLE suppliers("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "name TEXT UNIQUE,"
          "total_amount REAL DEFAULT 0,"
          "paid_amount REAL DEFAULT 0,"
          "remaining_amount REAL DEFAULT 0,"
          "date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
          ")",
        );

        await db.execute(
          "CREATE TABLE payments("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "supplier_id INTEGER,"
          "supplier_name TEXT,"
          "amount_paid REAL,"
          "payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,"
          "FOREIGN KEY(supplier_id) REFERENCES suppliers(id) ON DELETE CASCADE"
          ")",
        );

        await db.execute(
          "CREATE TABLE payment_history("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "supplier_id INTEGER,"
          "supplier_name TEXT,"
          "amount_paid REAL,"
          "payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,"
          "deletion_date TIMESTAMP,"
          "FOREIGN KEY(supplier_id) REFERENCES suppliers(id) ON DELETE CASCADE"
          ")",
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE suppliers ADD COLUMN total_amount REAL DEFAULT 0",
          );
          await db.execute(
            "ALTER TABLE suppliers ADD COLUMN paid_amount REAL DEFAULT 0",
          );
          await db.execute(
            "ALTER TABLE suppliers ADD COLUMN remaining_amount REAL DEFAULT 0",
          );
        }
        if (oldVersion < 3) {
          await db.execute(
            "CREATE TABLE payment_history("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "supplier_id INTEGER,"
            "supplier_name TEXT,"
            "amount_paid REAL,"
            "payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,"
            "deletion_date TIMESTAMP,"
            "FOREIGN KEY(supplier_id) REFERENCES suppliers(id)"
            ")",
          );
        }
      },
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> closeDatabase() async {
    final db = await database;
    db.close();
  }
}
