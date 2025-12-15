// lib/database/database_helper.dart (আপডেট করুন)
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../Model/user.dart';

class DatabaseHelper {
  static const String _databaseName = 'app_database.db';
  static const int _databaseVersion = 2; // ✅ Version increase for schema change

  // Table names
  static const String tableUsers = 'users';

  // Column names for users table
  static const String columnId = 'id';
  static const String columnUsername = 'username';
  static const String columnPassword = 'password';
  static const String columnEmail = 'email';
  static const String columnFullName = 'full_name';
  static const String columnRoles = 'roles';
  static const String columnIsActive = 'is_active'; // ✅ NEW column
  static const String columnToken = 'token';
  static const String columnType = 'type';
  static const String columnEmployeeCode = 'employee_code';
  static const String columnDesignation = 'designation';

  // Singleton instance
  static Database? _database;
  static DatabaseHelper? _instance;

  DatabaseHelper._private();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._private();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // ✅ Add upgrade handler
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableUsers (
        $columnId INTEGER PRIMARY KEY,
        $columnUsername TEXT NOT NULL UNIQUE,
        $columnPassword TEXT NOT NULL,
        $columnEmail TEXT NOT NULL,
        $columnFullName TEXT NOT NULL,
        $columnRoles TEXT NOT NULL,
        $columnIsActive INTEGER NOT NULL DEFAULT 1, -- ✅ NEW: is_active column
        $columnToken TEXT,
        $columnType TEXT,
        $columnEmployeeCode TEXT,
        $columnDesignation TEXT
      )
    ''');

    // Insert demo users
    await _insertDemoUsers(db);
  }

  // ✅ NEW: Handle database upgrade
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add is_active column if upgrading from version 1
      await db.execute('''
        ALTER TABLE $tableUsers 
        ADD COLUMN $columnIsActive INTEGER NOT NULL DEFAULT 1
      ''');

      // Update existing users to be active by default
      await db.update(tableUsers, {columnIsActive: 1});
    }
  }

  Future<void> _insertDemoUsers(Database db) async {
    // Demo users with is_active field
    final demoUsers = [
      {
        columnId: 1,
        columnUsername: 'admin',
        columnPassword: 'admin123', // In real app, this should be hashed
        columnEmail: 'admin@company.com',
        columnFullName: 'System Administrator',
        columnRoles: 'ROLE_ADMIN',
        columnIsActive: 1, // ✅ Active
        columnEmployeeCode: null,
        columnDesignation: 'System Admin',
      },
      {
        columnId: 2,
        columnUsername: 'manager',
        columnPassword: 'manager123',
        columnEmail: 'manager@company.com',
        columnFullName: 'John Manager',
        columnRoles: 'ROLE_MANAGER',
        columnIsActive: 1, // ✅ Active
        columnEmployeeCode: 'M001',
        columnDesignation: 'Production Manager',
      },
      {
        columnId: 3,
        columnUsername: 'inactive_user',
        columnPassword: 'inactive123',
        columnEmail: 'inactive@company.com',
        columnFullName: 'Inactive User',
        columnRoles: 'ROLE_EMPLOYEE',
        columnIsActive: 0, // ✅ Inactive for testing
        columnEmployeeCode: 'EMP999',
        columnDesignation: 'Former Employee',
      },
      {
        columnId: 4,
        columnUsername: 'hr_user',
        columnPassword: 'hr123',
        columnEmail: 'hr@company.com',
        columnFullName: 'Sarah HR',
        columnRoles: 'ROLE_HR',
        columnIsActive: 1,
        columnEmployeeCode: 'HR001',
        columnDesignation: 'HR Manager',
      },
      {
        columnId: 5,
        columnUsername: 'accountant',
        columnPassword: 'account123',
        columnEmail: 'account@company.com',
        columnFullName: 'David Accountant',
        columnRoles: 'ROLE_ACCOUNTANT',
        columnIsActive: 1,
        columnEmployeeCode: 'ACC001',
        columnDesignation: 'Chief Accountant',
      },
    ];

    for (final user in demoUsers) {
      await db.insert(
        tableUsers,
        user,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Authenticate user
  Future<User?> authenticateUser(String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableUsers,
      where: '$columnUsername = ? AND $columnPassword = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return User(
        id: map[columnId],
        username: map[columnUsername],
        email: map[columnEmail],
        fullName: map[columnFullName],
        roles: (map[columnRoles] as String).split(','),
        isActive: map[columnIsActive] == 1, // ✅ Convert to bool
      );
    }
    return null;
  }

  // ✅ NEW: Get user by username
  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableUsers,
      where: '$columnUsername = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return User(
        id: map[columnId],
        username: map[columnUsername],
        email: map[columnEmail],
        fullName: map[columnFullName],
        roles: (map[columnRoles] as String).split(','),
        isActive: map[columnIsActive] == 1,
      );
    }
    return null;
  }

  // ✅ NEW: Update user (for demo mode user management)
  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      tableUsers,
      {
        columnUsername: user.username,
        columnEmail: user.email,
        columnFullName: user.fullName,
        columnRoles: user.roles.join(','),
        columnIsActive: user.isActive ? 1 : 0,
        columnEmployeeCode: user.employeeCode,
        columnDesignation: user.designation,
      },
      where: '$columnId = ?',
      whereArgs: [user.id],
    );
  }

  // ✅ NEW: Get all users (for demo mode user management)
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableUsers);

    return List.generate(maps.length, (i) {
      final map = maps[i];
      return User(
        id: map[columnId],
        username: map[columnUsername],
        email: map[columnEmail],
        fullName: map[columnFullName],
        roles: (map[columnRoles] as String).split(','),
        isActive: map[columnIsActive] == 1,
        employeeCode: map[columnEmployeeCode],
        designation: map[columnDesignation],
      );
    });
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
