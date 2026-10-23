import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/workout_plan.dart';
import 'prebuilt_plans.dart';

// This class opens the app's SQLite database and creates its tables.
// Only one copy of this class exists, so the whole app shares one connection.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // The constructor is private so other files must use DatabaseHelper.instance.
  DatabaseHelper._init();

  // This getter opens the database the first time and reuses it after that.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('homefit.db');
    return _database!;
  }

  // This method finds the database file on the phone and opens it.
  Future<Database> _initDB(String fileName) async {
    final dbFolder = await getDatabasesPath();
    final path = join(dbFolder, fileName);

    return openDatabase(
      path,
      version: 1,
      onConfigure: _onConfigure,
      onCreate: _createDB,
    );
  }

  // SQLite ignores foreign keys unless this setting is turned on every time.
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // This method runs only once, when the database file is first created.
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workout_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        focus_area TEXT NOT NULL,
        exercises_json TEXT NOT NULL,
        est_minutes INTEGER NOT NULL,
        is_prebuilt INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Deleting a plan also deletes its logged sets because of ON DELETE CASCADE.
    // The CHECK rule stops a set with zero or too many reps from being saved.
    await db.execute('''
      CREATE TABLE training_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL,
        session_key TEXT NOT NULL,
        exercise_label TEXT NOT NULL,
        amount INTEGER NOT NULL CHECK (amount BETWEEN 1 AND 500),
        unit TEXT NOT NULL,
        logged_at TEXT NOT NULL,
        session_finished INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (workout_id) REFERENCES workout_plans (id)
          ON DELETE CASCADE
      )
    ''');

    // The pre-built plans are added here because onCreate runs only once.
    for (final plan in PrebuiltPlans.all()) {
      await db.insert('workout_plans', plan.toMap());
    }
  }

  // This method reads every plan, with pre-built plans first and then by id.
  Future<List<WorkoutPlan>> getAllPlans() async {
    final db = await database;
    final rows = await db.query(
      'workout_plans',
      orderBy: 'is_prebuilt DESC, id ASC',
    );
    return rows.map((row) => WorkoutPlan.fromMap(row)).toList();
  }

  // This method closes the connection and clears it so it can be reopened later.
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
