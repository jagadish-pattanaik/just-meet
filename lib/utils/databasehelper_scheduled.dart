import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:jagu_meet/model/note.dart';

class DatabaseHelper2 {
  static final DatabaseHelper2 _instance = new DatabaseHelper2.internal();

  factory DatabaseHelper2() => _instance;

  final String tableSchedule = 'scheduleTable';
  final String columnId2 = 'id2';
  final String columnTitle2 = 'title2';
  final String columnDescription2 = 'description2';
  final String date2 = 'date2';
  final String from2 = 'from2';
  final String to2 = 'to2';
  final String repeat = 'repeat';
  final String chatEnabled2 = 'chatEnabled2';
  final String liveEnabled2 = 'liveEnabled2';
  final String recordEnabled2 = 'recordEnabled2';
  final String raiseEnabled2 = 'raiseEnabled2';
  final String shareYtEnabled2 = 'shareYtEnabled2';
  final String kickOutEnabled2 = 'kickOutEnabled2';

  static Database _db2;

  DatabaseHelper2.internal();

  Future<Database> get db2 async {
    if (_db2 != null) {
      return _db2;
    }
    _db2 = await initDb2();

    return _db2;
  }

  initDb2() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'schedule.db');

//    await deleteDatabase(path); // just for testing

    var db2 = await openDatabase(path, version: 1, onCreate: _onCreate2);
    return db2;
  }

  void _onCreate2(Database db2, int newVersion) async {
    await db2.execute(
        'CREATE TABLE $tableSchedule($columnId2 INTEGER PRIMARY KEY, $columnTitle2 TEXT, $columnDescription2 TEXT, $date2 TEXT, $from2 TEXT, $to2 TEXT, $repeat TEXT, $chatEnabled2 INTEGER, $liveEnabled2 INTEGER, $recordEnabled2 INTEGER, $raiseEnabled2 INTEGER, $shareYtEnabled2 INTEGER, $kickOutEnabled2 INTEGER)');
  }

    Future<int> saveNote2(Note2 note2) async {
      var dbClient2 = await db2;
      var result = await dbClient2.insert(tableSchedule, note2.toMap());
//    var result = await dbClient.rawInsert(
//        'INSERT INTO $tableNote ($columnTitle, $columnDescription) VALUES (\'${note.title}\', \'${note.description}\')');

      return result;
    }

    Future<List> getAllNotes2() async {
      var dbClient2 = await db2;
      var result = await dbClient2.query(tableSchedule,
          columns: [columnId2, columnTitle2, columnDescription2, date2, from2, to2, repeat, chatEnabled2, liveEnabled2, recordEnabled2, raiseEnabled2, shareYtEnabled2, kickOutEnabled2]);
//    var result = await dbClient.rawQuery('SELECT * FROM $tableNote');

      return result.toList();
    }

    Future<int> getCount2() async {
      var dbClient2 = await db2;
      return Sqflite.firstIntValue(
          await dbClient2.rawQuery('SELECT COUNT(*) FROM $tableSchedule'));
    }

    Future<Note2> getNote2(int id) async {
      var dbClient2 = await db2;
      List<Map> result = await dbClient2.query(tableSchedule,
          columns: [columnId2, columnTitle2, columnDescription2, date2, from2, to2, repeat, chatEnabled2, liveEnabled2, recordEnabled2, raiseEnabled2, shareYtEnabled2, kickOutEnabled2],
          where: '$columnId2 = ?',
          whereArgs: [id]);
//    var result = await dbClient.rawQuery('SELECT * FROM $tableNote WHERE $columnId = $id');

      if (result.length > 0) {
        return new Note2.fromMap(result.first);
      }

      return null;
    }

    Future<int> deleteNote2(int id) async {
      var dbClient2 = await db2;
      return await dbClient2.delete(
          tableSchedule, where: '$columnId2 = ?', whereArgs: [id]);
//    return await dbClient.rawDelete('DELETE FROM $tableNote WHERE $columnId = $id');
    }

    Future<int> updateNote2(Note2 note2) async {
      var dbClient2 = await db2;
      return await dbClient2.update(
          tableSchedule, note2.toMap(), where: "$columnId2 = ?",
          whereArgs: [note2.id2]);
//    return await dbClient.rawUpdate(
//        'UPDATE $tableNote SET $columnTitle = \'${note.title}\', $columnDescription = \'${note.description}\' WHERE $columnId = ${note.id}');
    }

    Future close2() async {
      var dbClient2 = await db2;
      return dbClient2.close();
    }
}