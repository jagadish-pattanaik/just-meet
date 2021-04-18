import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:jagu_meet/model/note.dart';

class DatabaseHelper1 {
  static final DatabaseHelper1 _instance = new DatabaseHelper1.internal();

  factory DatabaseHelper1() => _instance;

  final String tableHost = 'hostTable';
  final String columnId1 = 'id1';
  final String columnTitle1 = 'title1';
  final String columnDescription1 = 'description1';
  final String columnTime1 = 'time1';
  final String chatEnabled1 = 'chatEnabled1';
  final String liveEnabled1 = 'liveEnabled1';
  final String recordEnabled1 = 'recordEnabled1';
  final String raiseEnabled1 = 'raiseEnabled1';
  final String shareYtEnabled1 = 'shareYtEnabled1';
  final String kickOutEnabled1 = 'kickOutEnabled1';

  static Database _db1;

  DatabaseHelper1.internal();

  Future<Database> get db1 async {
    if (_db1 != null) {
      return _db1;
    }
    _db1 = await initDb1();

    return _db1;
  }

  initDb1() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'host.db');

//    await deleteDatabase(path); // just for testing

    var db1= await openDatabase(path, version: 1, onCreate: _onCreate);
    return db1;
  }

  void _onCreate(Database db1, int newVersion) async {
    await db1.execute(
        'CREATE TABLE $tableHost($columnId1 INTEGER PRIMARY KEY, $columnTitle1 TEXT, $columnDescription1 TEXT, $columnTime1 TEXT, '
            '$chatEnabled1 INTEGER, $liveEnabled1 INTEGER, $recordEnabled1 INTEGER, $raiseEnabled1 INTEGER, $shareYtEnabled1 INTEGER, '
            '$kickOutEnabled1 INTEGER)');
  }

  Future<int> saveNote1(Note1 note1) async {
    var dbClient1 = await db1;
    var result = await dbClient1.insert(tableHost, note1.toMap());
//    var result = await dbClient.rawInsert(
//        'INSERT INTO $tableNote ($columnTitle, $columnDescription) VALUES (\'${note.title}\', \'${note.description}\')');

    return result;
  }

  Future<List> getAllNotes1() async {
    var dbClient1 = await db1;
    var result = await dbClient1.query(tableHost, columns: [columnId1, columnTitle1, columnDescription1, columnTime1,
      chatEnabled1, liveEnabled1, recordEnabled1, raiseEnabled1, shareYtEnabled1, kickOutEnabled1,]);
//    var result = await dbClient.rawQuery('SELECT * FROM $tableNote');

    return result.toList();
  }

  Future<int> getCount1() async {
    var dbClient1 = await db1;
    return Sqflite.firstIntValue(await dbClient1.rawQuery('SELECT COUNT(*) FROM $tableHost'));
  }

  Future<Note1> getNote1(int id1) async {
    var dbClient1 = await db1;
    List<Map> result = await dbClient1.query(tableHost,
        columns: [columnId1, columnTitle1, columnDescription1, columnTime1, chatEnabled1, liveEnabled1, recordEnabled1, raiseEnabled1,
          shareYtEnabled1, kickOutEnabled1,],
        where: '$columnId1 = ?',
        whereArgs: [id1]);
//    var result = await dbClient.rawQuery('SELECT * FROM $tableNote WHERE $columnId = $id');

    if (result.length > 0) {
      return new Note1.fromMap(result.first);
    }

    return null;
  }

  Future<int> deleteNote1(int id1) async {
    var dbClient1 = await db1;
    return await dbClient1.delete(tableHost, where: '$columnId1 = ?', whereArgs: [id1]);
//    return await dbClient.rawDelete('DELETE FROM $tableNote WHERE $columnId = $id');
  }


  Future<int> cleanNote1() async {
    var dbClient1 = await db1;
    return await dbClient1.delete(tableHost);
//    return await dbClient.rawDelete('DELETE FROM $tableNote WHERE $columnId = $id');
  }

  Future<int> updateNote1(Note1 note1) async {
    var dbClient1 = await db1;
    return await dbClient1.update(tableHost, note1.toMap(), where: "$columnId1 = ?", whereArgs: [note1.id1]);
//    return await dbClient.rawUpdate(
//        'UPDATE $tableNote SET $columnTitle = \'${note.title}\', $columnDescription = \'${note.description}\' WHERE $columnId = ${note.id}');
  }

  Future close1() async {
    var dbClient1 = await db1;
    return dbClient1.close();
  }
}