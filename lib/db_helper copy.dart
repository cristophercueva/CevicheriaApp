import 'package:pedidos_app/gastos.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:pedidos_app/pedido.dart';
import 'package:pedidos_app/plato.dart';

class DBHelper {
  //Gastos Database

  static Future<Database> _getDBGastos() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, 'gastos.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE gastos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT,
            precio DOUBLE,
            cantidad TEXT,
            tipo TEXT,
            fecha TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertarGastos(Gastos gastos) async {
    final db = await _getDBGastos();
    await db.insert(
      'gastos',
      gastos.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Gastos>> obtenerTodosGastos() async {
    final db = await _getDBGastos();
    final List<Map<String, dynamic>> maps = await db.query('gastos');
    return List.generate(maps.length, (i) => Gastos.fromMap(maps[i]));
  }

  static Future<List<Gastos>> obtenerGastosDeHoy() async {
    final db = await _getDBGastos();

    final DateTime hoy = DateTime.now();
    final DateTime fechaSinHora = DateTime(hoy.year, hoy.month, hoy.day);
    final String fechaISO = fechaSinHora.toIso8601String();

    final List<Map<String, dynamic>> maps = await db.query(
      'gastos',
      where: "fecha >= ? AND fecha < ?",
      whereArgs: [
        fechaISO,
        DateTime(hoy.year, hoy.month, hoy.day + 1).toIso8601String(),
      ],
    );

    return List.generate(maps.length, (i) => Gastos.fromMap(maps[i]));
  }

  static Future<List<Gastos>> obtenerGastosPorFecha(DateTime fecha) async {
    final db = await _getDBGastos();
    final hoy = DateTime(fecha.year, fecha.month, fecha.day);
    final manana = hoy.add(Duration(days: 1));

    final maps = await db.query(
      'gastos',
      where: 'fecha >= ? AND fecha < ?',
      whereArgs: [hoy.toIso8601String(), manana.toIso8601String()],
    );
    return List.generate(maps.length, (i) => Gastos.fromMap(maps[i]));
  }

  static Future<void> actualizarGasto(Gastos gasto) async {
    final db = await _getDBGastos();
    await db.update(
      'gastos',
      gasto.toMap(),
      where: 'id = ?',
      whereArgs: [gasto.id],
    );
  }

  static Future<void> eliminarGasto(int id) async {
    final db = await _getDBGastos();
    await db.delete('gastos', where: 'id = ?', whereArgs: [id]);
  }

  //Pedidos Database

  static Future<Database> _getDB() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, 'pedidos.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE pedidos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            plato TEXT,
            cantidad INTEGER,
            preciobase DOUBLE,
            preciofinal DOUBLE,
            tipo TEXT,
            fecha TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertarPedido(Pedido pedido) async {
    final db = await _getDB();
    await db.insert(
      'pedidos',
      pedido.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Pedido>> obtenerTodosPedidos() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query('pedidos');
    return List.generate(maps.length, (i) => Pedido.fromMap(maps[i]));
  }

  static Future<List<Pedido>> obtenerPedidosDeHoy() async {
    final db = await _getDB();

    final DateTime hoy = DateTime.now();
    final DateTime fechaSinHora = DateTime(hoy.year, hoy.month, hoy.day);
    final String fechaISO = fechaSinHora.toIso8601String();

    final List<Map<String, dynamic>> maps = await db.query(
      'pedidos',
      where: "fecha >= ? AND fecha < ?",
      whereArgs: [
        fechaISO,
        DateTime(hoy.year, hoy.month, hoy.day + 1).toIso8601String(),
      ],
    );

    return List.generate(maps.length, (i) => Pedido.fromMap(maps[i]));
  }

  static Future<List<Pedido>> obtenerPedidosPorFecha(DateTime fecha) async {
    final db = await _getDB();
    final hoy = DateTime(fecha.year, fecha.month, fecha.day);
    final manana = hoy.add(Duration(days: 1));

    final maps = await db.query(
      'pedidos',
      where: 'fecha >= ? AND fecha < ?',
      whereArgs: [hoy.toIso8601String(), manana.toIso8601String()],
    );
    return List.generate(maps.length, (i) => Pedido.fromMap(maps[i]));
  }

  static Future<void> actualizarPedido(Pedido pedido) async {
    final db = await _getDB();
    await db.update(
      'pedidos',
      pedido.toMap(),
      where: 'id = ?',
      whereArgs: [pedido.id],
    );
  }

  static Future<void> eliminarPedido(int id) async {
    final db = await _getDB();
    await db.delete('pedidos', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> borrarBaseDeDatos() async {
    final path = await getDatabasesPath();
    await deleteDatabase(join(path, 'pedidos.db'));
  }

  // Platos Database

  static Future<Database> _getDBPlatos() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, 'platos.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE platos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
             plato TEXT, 
            precio DOUBLE,
            tipo TEXT,
            fecha TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertarPlato(Plato plato) async {
    final db = await _getDBPlatos();
    await db.insert(
      'platos',
      plato.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Plato>> obtenerTodosPlatos() async {
    final db = await _getDBPlatos();
    final List<Map<String, dynamic>> maps = await db.query('platos');
    return List.generate(maps.length, (i) => Plato.fromMap(maps[i]));
  }

  static Future<void> actualizarPlato(Plato gasto) async {
    final db = await _getDBPlatos();
    await db.update(
      'platos',
      gasto.toMap(),
      where: 'id = ?',
      whereArgs: [gasto.id],
    );
  }

  static Future<void> eliminarPlato(int id) async {
    final db = await _getDBPlatos();
    await db.delete('platos', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> borrarBaseDeDatosPlato() async {
    final path = await getDatabasesPath();
    await deleteDatabase(join(path, 'platos.db'));
  }
}
