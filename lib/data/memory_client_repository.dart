import '../models/client.dart';
import 'client_repository.dart';

class MemoryClientRepository implements ClientRepository {
  final List<Client> _clients = [];
  int _nextId = 1;

  @override
  Future<void> initialize() async {}

  @override
  Future<List<Client>> getClients({String query = ''}) async {
    final value = query.toLowerCase();
    return _clients
        .where((c) =>
            c.name.toLowerCase().contains(value) || c.phone.contains(value))
        .toList();
  }

  @override
  Future<Client> save(Client client) async {
    if (client.id == null) {
      final saved = client.copyWith(id: _nextId++);
      _clients.add(saved);
      return saved;
    }
    final index = _clients.indexWhere((item) => item.id == client.id);
    if (index >= 0) _clients[index] = client;
    return client;
  }

  @override
  Future<void> delete(int id) async => _clients.removeWhere((c) => c.id == id);
}
