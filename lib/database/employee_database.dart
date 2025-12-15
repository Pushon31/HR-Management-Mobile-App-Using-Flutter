// lib/database/employee_database.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class EmployeeDatabase {
  static final EmployeeDatabase instance = EmployeeDatabase._init();

  static Database? _database;

  EmployeeDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('employees.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    // Employees table
    await db.execute('''
      CREATE TABLE employees(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        employee_id TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone_number TEXT,
        designation TEXT,
        department_id INTEGER,
        department_name TEXT,
        join_date TEXT,
        status TEXT DEFAULT 'ACTIVE',
        work_type TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Insert demo employees
    await _insertDemoEmployees(db);
  }

  Future<void> _insertDemoEmployees(Database db) async {
    final demoEmployees = [
      {
        'user_id': 1,
        'first_name': 'Admin',
        'last_name': 'User',
        'employee_id': 'EMP001',
        'email': 'admin@garment.com',
        'designation': 'Administrator',
        'department_name': 'Management',
        'join_date': '2024-01-01',
        'status': 'ACTIVE',
        'work_type': 'ONSITE',
      },
      {
        'user_id': 2,
        'first_name': 'Manager',
        'last_name': 'User',
        'employee_id': 'EMP002',
        'email': 'manager@garment.com',
        'designation': 'Manager',
        'department_name': 'Management',
        'join_date': '2024-01-15',
        'status': 'ACTIVE',
        'work_type': 'ONSITE',
      },
      {
        'user_id': 3,
        'first_name': 'HR',
        'last_name': 'Manager',
        'employee_id': 'EMP003',
        'email': 'hr@garment.com',
        'designation': 'HR Manager',
        'department_name': 'Human Resources',
        'join_date': '2024-02-01',
        'status': 'ACTIVE',
        'work_type': 'HYBRID',
      },
      {
        'user_id': 4,
        'first_name': 'Accountant',
        'last_name': 'User',
        'employee_id': 'EMP004',
        'email': 'accountant@garment.com',
        'designation': 'Accountant',
        'department_name': 'Finance',
        'join_date': '2024-02-15',
        'status': 'ACTIVE',
        'work_type': 'ONSITE',
      },
      {
        'user_id': 5,
        'first_name': 'Employee',
        'last_name': 'User',
        'employee_id': 'EMP005',
        'email': 'employee@garment.com',
        'designation': 'Production Staff',
        'department_name': 'Production',
        'join_date': '2024-03-01',
        'status': 'ACTIVE',
        'work_type': 'ONSITE',
      },
      {
        'user_id': 6,
        'first_name': 'John',
        'last_name': 'Smith',
        'employee_id': 'EMP006',
        'email': 'john@garment.com',
        'designation': 'Supervisor',
        'department_name': 'Production',
        'join_date': '2024-03-15',
        'status': 'ACTIVE',
        'work_type': 'ONSITE',
      },
      {
        'user_id': 7,
        'first_name': 'Sarah',
        'last_name': 'Johnson',
        'employee_id': 'EMP007',
        'email': 'sarah@garment.com',
        'designation': 'Quality Control',
        'department_name': 'Quality',
        'join_date': '2024-04-01',
        'status': 'INACTIVE',
        'work_type': 'REMOTE',
      },
      {
        'user_id': 8,
        'first_name': 'Mike',
        'last_name': 'Williams',
        'employee_id': 'EMP008',
        'email': 'mike@garment.com',
        'designation': 'Production Staff',
        'department_name': 'Production',
        'join_date': '2024-04-15',
        'status': 'ACTIVE',
        'work_type': 'ONSITE',
      },
    ];

    for (var employee in demoEmployees) {
      await db.insert('employees', employee);
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
