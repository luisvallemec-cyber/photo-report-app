import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/photo_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'photo_report.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        parent_id TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE photos (
        id TEXT PRIMARY KEY,
        category_id TEXT NOT NULL,
        image_path TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // ── Category helpers ────────────────────────────────────────────────────────

  Future<void> insertCategory(Category category) async {
    final db = await database;
    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  /// Deletes a category and recursively deletes all its sub-categories,
  /// their associated photos from the database, and the category itself.
  /// Note: photo files on disk are NOT removed here; callers are responsible
  /// for deleting the physical files if needed.
  Future<void> deleteCategory(String id) async {
    final db = await database;
    // Recursively delete children first
    final children = await db.query(
      'categories',
      where: 'parent_id = ?',
      whereArgs: [id],
    );
    for (final child in children) {
      await deleteCategory(child['id'] as String);
    }
    await db.delete('photos', where: 'category_id = ?', whereArgs: [id]);
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // ── Photo helpers ────────────────────────────────────────────────────────────

  Future<void> insertPhoto(PhotoItem photo) async {
    final db = await database;
    await db.insert(
      'photos',
      photo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PhotoItem>> getPhotosByCategory(String categoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'photos',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => PhotoItem.fromMap(m)).toList();
  }

  Future<List<PhotoItem>> getAllPhotos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('photos', orderBy: 'created_at DESC');
    return maps.map((m) => PhotoItem.fromMap(m)).toList();
  }

  Future<void> deletePhoto(String id) async {
    final db = await database;
    await db.delete('photos', where: 'id = ?', whereArgs: [id]);
  }
}
