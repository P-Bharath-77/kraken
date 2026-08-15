import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/client.dart';
import 'client_repository.dart';

class LocalClientRepository implements ClientRepository {
  Database? _database;

  @override
  Future<void> initialize() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'dnd_gym.db'),
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE clients(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT NOT NULL,
          age INTEGER NOT NULL,
          height REAL NOT NULL,
          weight REAL NOT NULL,
          injuries TEXT NOT NULL,
          diet_notes TEXT NOT NULL,
          fitness_goal TEXT NOT NULL,
          payment_date TEXT NOT NULL,
          membership_end_date TEXT NOT NULL,
          photo_path TEXT
        )
      '''),
    );
  }

  Database get _db => _database ?? (throw StateError('Repository not initialized'));

  @override
  Future<List<Client>> getClients({String query = ''}) async {
    final rows = await _db.query(
      'clients',
      where: query.trim().isEmpty ? null : '(name LIKE ? OR phone LIKE ?)',
      whereArgs: query.trim().isEmpty
          ? null
          : ['%${query.trim()}%', '%${query.trim()}%'],
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(Client.fromMap).toList();
  }

  @override
  Future<Client> save(Client client) async {
    final values = client.toMap()..remove('id');
    if (client.id == null) {
      final id = await _db.insert('clients', values);
      return client.copyWith(id: id);
    }
    await _db.update('clients', values, where: 'id = ?', whereArgs: [client.id]);
    return client;
  }

  @override
  Future<void> delete(int id) async {
    await _db.delete('clients', where: 'id = ?', whereArgs: [id]);
  }
}
