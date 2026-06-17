import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/tercero_model.dart';
import '../models/producto_model.dart';
import '../models/movimiento_model.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();

  static Database? _db;

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'foodchain.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE terceros (
            id TEXT PRIMARY KEY,
            nombre TEXT NOT NULL,
            tipo TEXT NOT NULL,
            telefono TEXT,
            direccion TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE productos (
            id TEXT PRIMARY KEY,
            nombre TEXT NOT NULL,
            categoria TEXT,
            precio REAL NOT NULL,
            stock REAL NOT NULL,
            unidad TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE movimientos (
            id TEXT PRIMARY KEY,
            tipo TEXT NOT NULL,
            cantidad REAL NOT NULL,
            precioUnitario REAL NOT NULL,
            total REAL,
            productoId TEXT NOT NULL,
            productoNombre TEXT,
            terceroId TEXT,
            terceroNombre TEXT,
            fecha TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE cola_pendiente (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            metodo TEXT NOT NULL,
            endpoint TEXT NOT NULL,
            body TEXT,
            timestamp INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  // ── TERCEROS ───────────────────────────────────────────────

  Future<void> cacheTerceros(List<Tercero> lista) async {
    final database = await db;
    final batch = database.batch();
    batch.delete('terceros');
    for (final t in lista) {
      batch.insert('terceros', {
        'id': t.id,
        'nombre': t.nombre,
        'tipo': t.tipo,
        'telefono': t.telefono,
        'direccion': t.direccion,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<Tercero>> getTerceros() async {
    final database = await db;
    final rows = await database.query('terceros', orderBy: 'nombre ASC');
    return rows.map((r) => Tercero(
      id: r['id'] as String,
      nombre: r['nombre'] as String,
      tipo: r['tipo'] as String,
      telefono: r['telefono'] as String?,
      direccion: r['direccion'] as String?,
    )).toList();
  }

  // ── PRODUCTOS ──────────────────────────────────────────────

  Future<void> cacheProductos(List<Producto> lista) async {
    final database = await db;
    final batch = database.batch();
    batch.delete('productos');
    for (final p in lista) {
      batch.insert('productos', {
        'id': p.id,
        'nombre': p.nombre,
        'categoria': p.categoria,
        'precio': p.precio,
        'stock': p.stock,
        'unidad': p.unidad,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<Producto>> getProductos() async {
    final database = await db;
    final rows = await database.query('productos', orderBy: 'nombre ASC');
    return rows.map((r) => Producto(
      id: r['id'] as String,
      nombre: r['nombre'] as String,
      categoria: r['categoria'] as String?,
      precio: (r['precio'] as num).toDouble(),
      stock: (r['stock'] as num).toDouble(),
      unidad: r['unidad'] as String,
    )).toList();
  }

  Future<void> updateProductoLocal(Producto p) async {
    final database = await db;
    await database.update(
      'productos',
      {
        'nombre': p.nombre,
        'categoria': p.categoria,
        'precio': p.precio,
        'stock': p.stock,
        'unidad': p.unidad,
      },
      where: 'id = ?',
      whereArgs: [p.id],
    );
  }

  Future<void> deleteProductoLocal(String id) async {
    final database = await db;
    await database.delete('productos', where: 'id = ?', whereArgs: [id]);
  }

  // ── MOVIMIENTOS ────────────────────────────────────────────

  Future<void> cacheMovimientos(List<Movimiento> lista) async {
    final database = await db;
    final batch = database.batch();
    batch.delete('movimientos');
    for (final m in lista) {
      batch.insert('movimientos', {
        'id': m.id,
        'tipo': m.tipo,
        'cantidad': m.cantidad,
        'precioUnitario': m.precioUnitario,
        'total': m.total,
        'productoId': m.productoId,
        'productoNombre': m.productoNombre,
        'terceroId': m.terceroId,
        'terceroNombre': m.terceroNombre,
        'fecha': m.fecha?.toIso8601String(),
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<Movimiento>> getMovimientos() async {
    final database = await db;
    final rows = await database.query('movimientos', orderBy: 'fecha DESC');
    return rows.map((r) => Movimiento(
      id: r['id'] as String?,
      tipo: r['tipo'] as String,
      cantidad: (r['cantidad'] as num).toDouble(),
      precioUnitario: (r['precioUnitario'] as num).toDouble(),
      total: r['total'] != null ? (r['total'] as num).toDouble() : null,
      productoId: r['productoId'] as String,
      productoNombre: r['productoNombre'] as String?,
      terceroId: (r['terceroId'] as String?) ?? '',
      terceroNombre: r['terceroNombre'] as String?,
      fecha: r['fecha'] != null ? DateTime.tryParse(r['fecha'] as String) : null,
    )).toList();
  }

  Future<void> deleteMovimientoLocal(String? id) async {
    if (id == null) return;
    final database = await db;
    await database.delete('movimientos', where: 'id = ?', whereArgs: [id]);
  }

  // ── COLA DE PENDIENTES ─────────────────────────────────────

  Future<void> encolarOperacion({
    required String metodo,
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    final database = await db;
    await database.insert('cola_pendiente', {
      'metodo': metodo,
      'endpoint': endpoint,
      'body': body != null ? jsonEncode(body) : null,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getPendientes() async {
    final database = await db;
    return database.query('cola_pendiente', orderBy: 'timestamp ASC');
  }

  Future<void> eliminarPendiente(int id) async {
    final database = await db;
    await database.delete('cola_pendiente', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countPendientes() async {
    final database = await db;
    final result =
        await database.rawQuery('SELECT COUNT(*) as c FROM cola_pendiente');
    return (result.first['c'] as int?) ?? 0;
  }
}
