import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:sudo_cash/models/expense.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await _getDatabasePath();
    final path = join(dbPath, filePath);
    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(version: 1, onCreate: _createDB),
    );
  }

  Future<String> _getDatabasePath() async {
    if (Platform.isLinux || Platform.isWindows) {
      return "./";
    } else {
      return await getDatabasesPath();
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE USER (
      UserID INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      pwd TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE WALLETS (
      walletID INTEGER PRIMARY KEY AUTOINCREMENT,
      name_wallets TEXT NOT NULL,
      total REAL NOT NULL,
      wallet_limit REAL NOT NULL, 
      color TEXT NOT NULL,
      UserID INTEGER NOT NULL,
      FOREIGN KEY (UserID) REFERENCES USER(UserID) ON DELETE CASCADE
    )
    ''');

    await db.execute('''
    CREATE TABLE CATEGORY (
      categoryID INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      color TEXT NOT NULL,
      walletID INTEGER NOT NULL,
      FOREIGN KEY (walletID) REFERENCES WALLETS(walletID) ON DELETE CASCADE
    )
    ''');

    await db.execute('''
    CREATE TABLE EXPENSE (
      expenseID INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      amount REAL NOT NULL,
      date DATETIME NOT NULL,
      walletID INTEGER NOT NULL,
      categoryID INTEGER NOT NULL,
      expense_limit REAL NOT NULL DEFAULT 100.0,
      icon TEXT,
      FOREIGN KEY (walletID) REFERENCES WALLETS(walletID) ON DELETE CASCADE,
      FOREIGN KEY (categoryID) REFERENCES CATEGORY(categoryID) ON DELETE CASCADE
    )
    ''');
  }

  // USER Methods
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;
    final result = await db.query('USER', where: 'UserID = ?', whereArgs: [userId]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<String> insertUser(String name, String pwd) async {
    final db = await database;
    bool exists = await userExists(name);
    if (exists) return "L'utilisateur existe déjà";
    await db.insert('USER', {'name': name, 'pwd': pwd});
    return "Utilisateur créé avec succès";
  }

  Future<bool> userExists(String name) async {
    final db = await database;
    final result = await db.query('USER', where: 'name = ?', whereArgs: [name]);
    return result.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getUsersWithCredentials(String username, String password) async {
    final db = await database;
    return await db.query('USER', where: 'name = ? AND pwd = ?', whereArgs: [username, password]);
  }

  Future<int> deletePassword(int userId) async {
    final db = await database;
    return await db.update('USER', {'pwd': null}, where: 'UserID = ?', whereArgs: [userId]);
  }

  Future<int> updateUser(int userId, String name, String pwd) async {
    final db = await database;
    final existingUsers = await db.query('USER', where: 'name = ? AND UserID != ?', whereArgs: [name, userId]);
    if (existingUsers.isNotEmpty) throw Exception('Username "$name" is already taken');
    return await db.update('USER', {'name': name, 'pwd': pwd}, where: 'UserID = ?', whereArgs: [userId]);
  }

  // WALLETS Methods
  Future<int> insertWallet(String name, double total, double walletLimit, String color, int userId) async {
    final db = await database;
    return await db.insert('WALLETS', {
      'name_wallets': name,
      'total': total,
      'wallet_limit': walletLimit,
      'color': color,
      'UserID': userId,
    });
  }

  Future<List<Map<String, dynamic>>> getAllWallets() async {
    final db = await database;
    return await db.query('WALLETS');
  }

  Future<int> updateWallet(int id, String name, double total, double walletLimit, String color) async {
    final db = await database;
    return await db.update('WALLETS', {
      'name_wallets': name,
      'total': total,
      'wallet_limit': walletLimit,
      'color': color,
    }, where: 'walletID = ?', whereArgs: [id]);
  }

  Future<int> deleteWallet(int id) async {
    final db = await database;
    return await db.delete('WALLETS', where: 'walletID = ?', whereArgs: [id]);
  }

  // CATEGORY Methods
  Future<int> insertCategory(String name, String color, int walletId) async {
    final db = await database;
    return await db.insert('CATEGORY', {'name': name, 'color': color, 'walletID': walletId});
  }

  Future<List<Map<String, dynamic>>> getCategoriesByWallet(int walletId) async {
    final db = await database;
    List<Map<String, dynamic>> categories = await db.query('CATEGORY', where: 'walletID = ?', whereArgs: [walletId]);
    List<Map<String, dynamic>> mutableCategories = [];
    for (var category in categories) {
      double totalAmount = await getCategoryExpenseTotal(category['categoryID']);
      mutableCategories.add({...category, 'totalAmount': totalAmount});
    }
    return mutableCategories;
  }


  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;
    return await db.query('CATEGORY');
  }

  Future<int> updateCategory(int id, String name, String color) async {
    final db = await database;
    return await db.update('CATEGORY', {'name': name, 'color': color}, where: 'categoryID = ?', whereArgs: [id]);
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('CATEGORY', where: 'categoryID = ?', whereArgs: [id]);
  }

  Future<double> getCategoryExpenseTotal(int categoryId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM EXPENSE WHERE categoryID = ?',
      [categoryId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // EXPENSE Methods
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('EXPENSE', expense.toMap());
  }

  Future<List<Expense>> getExpenses(int walletId, int categoryId) async {
    final db = await database;
    final maps = await db.query(
      'EXPENSE',
      where: 'walletID = ? AND categoryID = ?',
      whereArgs: [walletId, categoryId],
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  Future<List<Map<String, dynamic>>> getAllExpenses() async {
    final db = await database;
    return await db.query('EXPENSE');
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update('EXPENSE', expense.toMap(), where: 'expenseID = ?', whereArgs: [expense.expenseID]);
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete('EXPENSE', where: 'expenseID = ?', whereArgs: [id]);
  }
}