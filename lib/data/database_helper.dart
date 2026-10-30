import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/training_log.dart';
import '../models/workout_plan.dart';
import '../models/workout_session.dart';
import '../models/workout_stats.dart';
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

  // This method saves one logged set and returns the id SQLite gave it.
  Future<int> insertLog(TrainingLog log) async {
    final db = await database;
    return db.insert('training_logs', log.toMap());
  }

  // This method reads every set with its plan title and groups them into sessions.
  Future<List<WorkoutSession>> getSessions() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT training_logs.*, workout_plans.title AS plan_title
      FROM training_logs
      JOIN workout_plans ON training_logs.workout_id = workout_plans.id
      ORDER BY training_logs.logged_at ASC, training_logs.id ASC
    ''');
    return WorkoutSession.groupRows(rows);
  }

  // This method works out the stats again from the saved sets.
  // COUNT(DISTINCT session_key) means three sets in one session count as one.
  Future<WorkoutStats> getStats() async {
    final db = await database;
    final weekStart = WorkoutStats.startOfWeek(DateTime.now());

    final sessionRows = await db.rawQuery(
      'SELECT COUNT(DISTINCT session_key) AS total FROM training_logs '
      'WHERE session_finished = ? AND logged_at >= ?',
      [1, weekStart.toIso8601String()],
    );
    final repRows = await db.rawQuery(
      'SELECT SUM(amount) AS total FROM training_logs WHERE unit = ?',
      ['reps'],
    );

    return WorkoutStats(
      sessionsThisWeek: (sessionRows.first['total'] as int?) ?? 0,
      // SUM returns null when there are no rows, so zero is used instead.
      totalReps: (repRows.first['total'] as int?) ?? 0,
    );
  }

  // This method finds when each plan was last finished, for Focus Match.
  // A plan that was never finished is not in the result.
  Future<Map<int, DateTime>> getLastFinishedTimes() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT workout_id, MAX(logged_at) AS last_done FROM training_logs '
      'WHERE session_finished = ? GROUP BY workout_id',
      [1],
    );
    return {
      for (final row in rows)
        row['workout_id'] as int: DateTime.parse(row['last_done'] as String),
    };
  }

  // This method reads the sets in one session, oldest first.
  Future<List<TrainingLog>> getLogsForSession(String sessionKey) async {
    final db = await database;
    final rows = await db.query(
      'training_logs',
      where: 'session_key = ?',
      whereArgs: [sessionKey],
      orderBy: 'logged_at ASC, id ASC',
    );
    return rows.map((row) => TrainingLog.fromMap(row)).toList();
  }

  // This method corrects the amount on one saved set.
  Future<int> updateLogAmount(int logId, int amount) async {
    final db = await database;
    return db.update(
      'training_logs',
      {'amount': amount},
      where: 'id = ?',
      whereArgs: [logId],
    );
  }

  // This method deletes one saved set.
  Future<int> deleteLog(int logId) async {
    final db = await database;
    return db.delete('training_logs', where: 'id = ?', whereArgs: [logId]);
  }

  // This method marks every set in a session as finished.
  Future<int> finishSession(String sessionKey) async {
    final db = await database;
    return db.update(
      'training_logs',
      {'session_finished': 1},
      where: 'session_key = ?',
      whereArgs: [sessionKey],
    );
  }

  // This method deletes every set in a session.
  Future<int> deleteSession(String sessionKey) async {
    final db = await database;
    return db.delete(
      'training_logs',
      where: 'session_key = ?',
      whereArgs: [sessionKey],
    );
  }

  // This method saves a new plan and returns the id SQLite gave it.
  Future<int> insertPlan(WorkoutPlan plan) async {
    final db = await database;
    return db.insert('workout_plans', plan.toMap());
  }

  // This method saves changes to an existing plan, found by its id.
  Future<int> updatePlan(WorkoutPlan plan) async {
    final db = await database;
    return db.update(
      'workout_plans',
      plan.toMap(),
      where: 'id = ?',
      whereArgs: [plan.id],
    );
  }

  // This method counts how many logged sets belong to a plan.
  // The delete dialog uses it to warn the user what else will be removed.
  Future<int> countLogsForPlan(int planId) async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM training_logs WHERE workout_id = ?',
      [planId],
    );
    return (rows.first['total'] as int?) ?? 0;
  }

  // This method deletes a plan and all of its logged sets together.
  // The transaction means either both deletes happen or neither does.
  Future<void> deletePlan(int planId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'training_logs',
        where: 'workout_id = ?',
        whereArgs: [planId],
      );
      await txn.delete('workout_plans', where: 'id = ?', whereArgs: [planId]);
    });
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

  // This method reads the user's own plans, with the newest first.
  Future<List<WorkoutPlan>> getPersonalPlans() async {
    final db = await database;
    final rows = await db.query(
      'workout_plans',
      where: 'is_prebuilt = ?',
      whereArgs: [0],
      orderBy: 'id DESC',
    );
    return rows.map((row) => WorkoutPlan.fromMap(row)).toList();
  }

  // This method reads only the pre-built plans shown on the Home screen.
  Future<List<WorkoutPlan>> getPrebuiltPlans() async {
    final db = await database;
    final rows = await db.query(
      'workout_plans',
      where: 'is_prebuilt = ?',
      whereArgs: [1],
      orderBy: 'id ASC',
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
