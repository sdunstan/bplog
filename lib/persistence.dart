import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String tableBP = "bp";
final String columnId = "_id";
final String columnTimestamp = "readingTime";
final String columnDia = "dia";
final String columnSys = "sys";
final String columnPulse = "pulse";

class BloodPressure {
  int id;
  int readingTime;
  int systolic;
  int diastolic;
  int pulse;

  BloodPressure();

  static BloodPressure fromDateTime(DateTime timestamp, int systolic, int diastolic, int pulse) {
    BloodPressure bp = BloodPressure();
    bp.readingTime = timestamp.millisecondsSinceEpoch;
    bp.systolic = systolic;
    bp.diastolic = diastolic;
    bp.pulse = pulse;

    return bp;
  }

  Map toMap() {
    Map<String, dynamic> map = {columnId: id,
      columnTimestamp: readingTime,
      columnSys: systolic,
      columnDia: diastolic,
      columnPulse: pulse};

    if (readingTime == null) {
      readingTime = DateTime.now().millisecondsSinceEpoch;
    }

    return map;
  }

  static BloodPressure fromMap(Map item) {
    BloodPressure bp = BloodPressure();
    bp.id = item[columnId];
    bp.readingTime = item[columnTimestamp];
    bp.diastolic = item[columnDia];
    bp.systolic = item[columnSys];
    bp.pulse = item[columnPulse];

    return bp;
  }
}

class BloodPressureProvider {

  Database db;

  Future open() async {
    var  databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'bplog.db');
    db = await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          create table $tableBP (
            $columnId integer primary key autoincrement,
            $columnTimestamp integer not null,
            $columnDia integer,
            $columnSys integer,
            $columnPulse integer )
            
        ''');
      });
  }

  Future<BloodPressure> insert(BloodPressure bp) async {
    bp.id = await db.insert(tableBP, bp.toMap());
    return bp;
  }

  Future<List<BloodPressure>> getAll() async {
    List<BloodPressure> bpResults = List<BloodPressure>();
    List<Map> results = await db.query(tableBP, orderBy: columnTimestamp);

    for (Map item in results) {
      bpResults.add(BloodPressure.fromMap(item));
    }
    return bpResults;
  }



  Future close() async => db.close();
}

