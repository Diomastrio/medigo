import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'models/medicine.dart';

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
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE medicines(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
          )
        ''');
        await _seedDatabase(db);
      },
    );
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
}
