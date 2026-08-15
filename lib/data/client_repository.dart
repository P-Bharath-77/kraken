import '../models/client.dart';

abstract interface class ClientRepository {
  Future<void> initialize();
  Future<List<Client>> getClients({String query = ''});
  Future<Client> save(Client client);
  Future<void> delete(int id);
}
