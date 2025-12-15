// lib/database/user_database.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../Model/user.dart';

class UserDatabase {
  static const String _databaseName = 'users.db';
  static const int _databaseVersion = 1;

  // Table name
  static const String tableUsers = 'users';

  // Column names
  static const String columnId = 'id';
  static const String columnUsername = 'username';
  static const String columnEmail = 'email';
  static const String columnFullName = 'full_name';
  static const String columnRoles = 'roles';
  static const String columnIsActive = 'is_active';
  static const String columnEmployeeCode = 'employee_code';
  static const String columnDesignation = 'designation';
  static const String columnCreatedAt = 'created_at';

  // Singleton instance
  static Database? _database;
  static UserDatabase? _instance;

  UserDatabase._private();

  factory UserDatabase() {
    _instance ??= UserDatabase._private();
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
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableUsers (
        $columnId INTEGER PRIMARY KEY,
        $columnUsername TEXT NOT NULL UNIQUE,
        $columnEmail TEXT NOT NULL,
        $columnFullName TEXT NOT NULL,
        $columnRoles TEXT NOT NULL,
        $columnIsActive INTEGER NOT NULL DEFAULT 1,
        $columnEmployeeCode TEXT,
        $columnDesignation TEXT,
        $columnCreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Insert demo users
    await _insertDemoUsers(db);
  }

  Future<void> _insertDemoUsers(Database db) async {
    final demoUsers = [
      User(
        id: 1,
        username: 'admin',
        email: 'admin@company.com',
        fullName: 'System Administrator',
        roles: ['ROLE_ADMIN'],
        isActive: true,
      ),
      User(
        id: 2,
        username: 'manager',
        email: 'manager@company.com',
        fullName: 'John Manager',
        roles: ['ROLE_MANAGER'],
        isActive: true,
        employeeCode: 'M001',
        designation: 'Production Manager',
      ),
      User(
        id: 3,
        username: 'hr_user',
        email: 'hr@company.com',
        fullName: 'Sarah HR',
        roles: ['ROLE_HR'],
        isActive: true,
        employeeCode: 'HR001',
        designation: 'HR Manager',
      ),
      User(
        id: 4,
        username: 'accountant',
        email: 'account@company.com',
        fullName: 'David Accountant',
        roles: ['ROLE_ACCOUNTANT'],
        isActive: true,
        employeeCode: 'ACC001',
        designation: 'Chief Accountant',
      ),
      User(
        id: 5,
        username: 'employee1',
        email: 'emp1@company.com',
        fullName: 'Rahim Ahmed',
        roles: ['ROLE_EMPLOYEE'],
        isActive: true,
        employeeCode: 'EMP001',
        designation: 'Tailor',
      ),
      User(
        id: 6,
        username: 'employee2',
        email: 'emp2@company.com',
        fullName: 'Karim Khan',
        roles: ['ROLE_EMPLOYEE'],
        isActive: false,
        employeeCode: 'EMP002',
        designation: 'Cutter',
      ),
      User(
        id: 7,
        username: 'employee3',
        email: 'emp3@company.com',
        fullName: 'Fatima Begum',
        roles: ['ROLE_EMPLOYEE'],
        isActive: true,
        employeeCode: 'EMP003',
        designation: 'Sewing Operator',
      ),
      User(
        id: 8,
        username: 'supervisor',
        email: 'supervisor@company.com',
        fullName: 'Mizan Supervisor',
        roles: ['ROLE_MANAGER', 'ROLE_EMPLOYEE'],
        isActive: true,
        employeeCode: 'SUP001',
        designation: 'Floor Supervisor',
      ),
    ];

    for (final user in demoUsers) {
      await db.insert(
        tableUsers,
        _userToMap(user),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Map<String, dynamic> _userToMap(User user) {
    return {
      columnId: user.id,
      columnUsername: user.username,
      columnEmail: user.email,
      columnFullName: user.fullName,
      columnRoles: user.roles.join(','),
      columnIsActive: user.isActive ? 1 : 0,
      columnEmployeeCode: user.employeeCode,
      columnDesignation: user.designation,
    };
  }

  User _mapToUser(Map<String, dynamic> map) {
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
  }

  // CRUD operations
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert(tableUsers, _userToMap(user));
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableUsers);
    return List.generate(maps.length, (i) => _mapToUser(maps[i]));
  }

  Future<User> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableUsers,
      where: '$columnId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _mapToUser(maps.first);
    } else {
      throw Exception('User not found');
    }
  }

  Future<User> getUserByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableUsers,
      where: '$columnUsername = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return _mapToUser(maps.first);
    } else {
      throw Exception('User not found');
    }
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      tableUsers,
      _userToMap(user),
      where: '$columnId = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(tableUsers, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<List<User>> getActiveUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableUsers,
      where: '$columnIsActive = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => _mapToUser(maps[i]));
  }

  Future<List<User>> getInactiveUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableUsers,
      where: '$columnIsActive = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => _mapToUser(maps[i]));
  }

  Future<List<User>> getUsersByRole(String roleName) async {
    final allUsers = await getAllUsers();
    return allUsers
        .where((user) => user.roles.any((role) => role.contains(roleName)))
        .toList();
  }

  Future<int> getUsersCount() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableUsers'),
    );
    return count ?? 0;
  }

  Future<int> getActiveUsersCount() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM $tableUsers WHERE $columnIsActive = 1',
      ),
    );
    return count ?? 0;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
