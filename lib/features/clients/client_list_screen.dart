import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/client_repository.dart';
import '../../models/client.dart';
import '../../widgets/client_avatar.dart';
import '../../widgets/empty_state.dart';
import 'client_form_screen.dart';
import 'client_profile_screen.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({required this.repository, required this.onChanged, super.key});
  final ClientRepository repository;
  final VoidCallback onChanged;

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final _search = TextEditingController();
  late Future<List<Client>> _clients;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reload() => setState(() => _clients = widget.repository.getClients(query: _search.text));

  Future<void> _openForm([Client? client]) async {
    final changed = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => ClientFormScreen(repository: widget.repository, client: client)));
    if (changed == true) {
      _reload();
      widget.onChanged();
    }
  }

  Future<void> _openProfile(Client client) async {
    final changed = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => ClientProfileScreen(repository: widget.repository, client: client)));
    if (changed == true) {
      _reload();
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Clients', style: TextStyle(fontWeight: FontWeight.bold))),
        floatingActionButton: FloatingActionButton.extended(onPressed: _openForm, icon: const Icon(Icons.person_add_alt_1), label: const Text('Add client')),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            child: TextField(
              controller: _search,
              onChanged: (_) => _reload(),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search name or phone'),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Client>>(
              future: _clients,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final clients = snapshot.data ?? [];
                if (clients.isEmpty) return EmptyState(title: _search.text.isEmpty ? 'No clients yet' : 'No results', message: _search.text.isEmpty ? 'Add your first client to start building your roster.' : 'Try another name or phone number.', icon: _search.text.isEmpty ? Icons.people_outline : Icons.search_off);
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                  itemCount: clients.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final client = clients[index];
                    return Card(child: ListTile(
                      onTap: () => _openProfile(client),
                      leading: ClientAvatar(name: client.name, photoPath: client.photoPath),
                      title: Text(client.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${client.phone}  •  ${client.fitnessGoal}', maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Icon(Icons.chevron_right, color: client.membershipActive ? AppColors.gold : AppColors.muted),
                    ));
                  },
                );
              },
            ),
          ),
        ]),
      );
}
