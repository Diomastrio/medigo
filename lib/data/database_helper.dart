import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'models/medicine.dart';
import 'models/reminder.dart';
import 'models/dose_history.dart';
import '../services/notification_service.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'medicine.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE medicines(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
          )
        ''');
        await _createRemindersTable(db);
        await _createDoseHistoryTable(db);
        await _seedDatabase(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createRemindersTable(db);
        }
        if (oldVersion < 3) {
          await _createDoseHistoryTable(db);
        }
      },
    );
  }

  Future<void> _createRemindersTable(Database db) async {
    await db.execute('''
      CREATE TABLE reminders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicineName TEXT,
        time TEXT,
        doseCount INTEGER,
        doseUnit TEXT,
        doseType TEXT,
        timing TEXT,
        duration INTEGER,
        durationType TEXT
      )
    ''');
  }

  Future<void> _createDoseHistoryTable(Database db) async {
    await db.execute('''
      CREATE TABLE dose_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reminderId INTEGER,
        medicineName TEXT,
        doseDetails TEXT,
        takenAt TEXT
      )
    ''');
  }

  Future<void> _seedDatabase(Database db) async {
    List<String> initialMedicines = [
      'Aspirin',
      'Ibuprofen',
      'Paracetamol',
      'Amoxicillin',
      'Ciprofloxacin',
      'Metformin',
      'Atorvastatin',
      'Omeprazole',
      'Losartan',
      'Amlodipine',
    ];

    for (String medicineName in initialMedicines) {
      await db.insert('medicines', {'name': medicineName});
    }
  }

  Future<List<Medicine>> getMedicines() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('medicines');

    return List.generate(maps.length, (i) {
      return Medicine.fromMap(maps[i]);
    });
  }

  Future<void> insertMedicine(Medicine medicine) async {
    final db = await database;
    await db.insert(
      'medicines',
      medicine.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteMedicine(int id) async {
    final db = await database;
    await db.delete('medicines', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addDoseHistory(Reminder reminder) async {
    final db = await database;
    final history = DoseHistory(
      reminderId: reminder.id!,
      medicineName: reminder.medicineName,
      doseDetails: '${reminder.doseCount} ${reminder.doseType} (${reminder.doseUnit})',
      takenAt: DateTime.now().toIso8601String(),
    );
    await db.insert('dose_history', history.toMap());
  }

  Future<List<DoseHistory>> getDoseHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('dose_history', orderBy: 'takenAt DESC');
    return List.generate(maps.length, (i) {
      return DoseHistory.fromMap(maps[i]);
    });
  }

  Future<List<Reminder>> getReminders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('reminders');
    return List.generate(maps.length, (i) {
      return Reminder.fromMap(maps[i]);
    });
  }

  Future<void> insertReminder(Reminder reminder) async {
    final db = await database;
    final id = await db.insert(
      'reminders',
      reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    final reminderWithId = Reminder(
      id: id,
      medicineName: reminder.medicineName,
      time: reminder.time,
      doseCount: reminder.doseCount,
      doseUnit: reminder.doseUnit,
      doseType: reminder.doseType,
      timing: reminder.timing,
      duration: reminder.duration,
      durationType: reminder.durationType,
    );
    
    await NotificationService().scheduleReminderNotification(reminderWithId);
    print('Reminder saved to database');
  }

  Future<void> updateReminder(Reminder reminder) async {
    final db = await database;
    await db.update(
      'reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
    
    await NotificationService().scheduleReminderNotification(reminder);
    print('Reminder updated in database');
  }

  Future<void> deleteReminder(int id) async {
    final db = await database;
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
    await NotificationService().cancelReminderNotification(id);
    print('Reminder deleted from database');
  }
}
