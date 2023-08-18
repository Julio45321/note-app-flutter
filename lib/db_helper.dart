import 'package:sqflite/sqflite.dart' as sql;

// creas la clase para hacer la inserción de datos

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE data(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT,
      desc TEXT,
      createdAT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP 
    )  """);
  }

// llamada a la base de datos
  static Future<sql.Database> db() async {
    return sql.openDatabase("databse_name.db", version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

// creas el dato insertado
  static Future<int> createData(String title, String? desc) async {
    final db = await SQLHelper.db();

    final data = {'title': title, 'desc': desc};
    final id = await db.insert('data', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

// para leer el dato obtenido desde el id generado automaticamente
  static Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await SQLHelper.db();
    return db.query('data', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getSingleData(int id) async {
    final db = await SQLHelper.db();
    return db.query('data', where: "id = ?", whereArgs: [id], limit: 1);
  }
// actualizar los datos 
  static Future<int> updateData(int id, String title, String? desc) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'desc': desc,
      'createdAT': DateTime.now().toString()
    };
    final result =
        await db.update('data', data, where: 'id = ?', whereArgs: [id]);
    return result;
  }

  static Future<void> deleteData(int id) async{
   final db = await SQLHelper.db();
   try{
    await db.delete('data', where: "id = ?", whereArgs: [id]);
   }catch (e){}
  }
}
