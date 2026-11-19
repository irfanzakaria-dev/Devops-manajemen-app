import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../features/work_notes/models/work_note.dart';

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
    // Inisialisasi FFI jika dijalankan di Windows/Linux Desktop
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'devops_management.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE work_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT,
        assigned_role TEXT,
        author_name TEXT,
        status TEXT,
        priority TEXT,
        git_branch TEXT,
        created_at TEXT
      )
    ''');

    // Masukkan data awal (seed) agar aplikasi langsung terisi dan mudah didemokan
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    final sampleNotes = [
      WorkNote(
        title: 'Membuat Form Login & Validasi Token',
        description: 'Tampilan autentikasi berbasis GitHub dan pemilihan 3 peran tim IT.',
        category: 'Fitur Baru',
        assignedRole: 'developer',
        authorName: 'Sarah Chen (Developer)',
        status: 'done',
        priority: 'Tinggi',
        gitBranch: 'feature/auth-login',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      ),
      WorkNote(
        title: 'Integrasi Database SQLite Lokal (Offline-First)',
        description: 'Menyimpan catatan kerja dan aktivitas tim langsung di memori HP agar bisa dibuka saat offline.',
        category: 'DevOps & Server',
        assignedRole: 'developer',
        authorName: 'Sarah Chen (Developer)',
        status: 'in_progress',
        priority: 'Kritis',
        gitBranch: 'feature/sqlite-local-db',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      ),
      WorkNote(
        title: 'Uji Coba Pengujian Fitur Offline Mode',
        description: 'Pastikan aplikasi tetap berjalan dan data catatan kerja tidak hilang saat wifi/data dimatikan.',
        category: 'Pengujian',
        assignedRole: 'qa',
        authorName: 'Raka Pratama (QA)',
        status: 'ready_for_qa',
        priority: 'Tinggi',
        gitBranch: 'test/offline-verification',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
      ),
      WorkNote(
        title: 'Persetujuan Rilis Aplikasi Versi v1.2',
        description: 'Meninjau checklist pengujian dari QA sebelum aplikasi dideploy ke server produksi.',
        category: 'DevOps & Server',
        assignedRole: 'lead',
        authorName: 'Alex Morgan (Lead)',
        status: 'todo',
        priority: 'Sedang',
        gitBranch: 'release/v1.2.0',
        createdAt: DateTime.now().toIso8601String(),
      ),
    ];

    for (final note in sampleNotes) {
      await db.insert('work_notes', note.toMap());
    }
  }

  // --- Operasi CRUD ---

  // 1. Ambil Semua Catatan Kerja
  Future<List<WorkNote>> getAllNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'work_notes',
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) => WorkNote.fromMap(maps[i]));
  }

  // 2. Ambil Catatan Berdasarkan Role
  Future<List<WorkNote>> getNotesByRole(String role) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'work_notes',
      where: 'assigned_role = ?',
      whereArgs: [role],
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) => WorkNote.fromMap(maps[i]));
  }

  // 3. Tambah Catatan Kerja Baru
  Future<int> insertNote(WorkNote note) async {
    final db = await database;
    return await db.insert('work_notes', note.toMap());
  }

  // 4. Update Catatan Kerja
  Future<int> updateNote(WorkNote note) async {
    final db = await database;
    return await db.update(
      'work_notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // 5. Update Status Catatan (misal saat diajukan ke QA atau Selesai)
  Future<int> updateNoteStatus(int id, String newStatus) async {
    final db = await database;
    return await db.update(
      'work_notes',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 6. Hapus Catatan Kerja
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(
      'work_notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
