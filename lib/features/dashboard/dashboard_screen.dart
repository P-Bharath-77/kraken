import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../data/client_repository.dart';
import '../../models/client.dart';
import '../../widgets/client_avatar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({required this.repository, required this.onOpenClients, super.key});
  final ClientRepository repository;
  final VoidCallback onOpenClients;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Client>> _clients;

  @override
  void initState() {
    super.initState();
    _clients = widget.repository.getClients();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('D&D GYM', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2))),
        body: FutureBuilder<List<Client>>(
          future: _clients,
          builder: (context, snapshot) {
            final clients = snapshot.data ?? [];
            final active = clients.where((c) => c.membershipActive).length;
            final expiring = clients.where((c) {
              final days = c.membershipEndDate.difference(DateTime.now()).inDays;
              return days >= 0 && days <= 7;
            }).toList();
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Text('Welcome back', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const Text('Your gym at a glance', style: TextStyle(color: AppColors.muted)),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(child: _StatCard(label: 'Total clients', value: '${clients.length}', icon: Icons.groups_2_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'Active plans', value: '$active', icon: Icons.workspace_premium_outlined)),
                ]),
                const SizedBox(height: 28),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Ending soon', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  TextButton(onPressed: widget.onOpenClients, child: const Text('View clients')),
                ]),
                if (expiring.isEmpty)
                  const Card(child: Padding(padding: EdgeInsets.all(22), child: Text('No memberships end in the next 7 days.', style: TextStyle(color: AppColors.muted))))
                else
                  ...expiring.take(4).map((client) => Card(
                        child: ListTile(
                          leading: ClientAvatar(name: client.name, photoPath: client.photoPath, radius: 22),
                          title: Text(client.name),
                          subtitle: Text('Ends ${DateFormat('dd MMM yyyy').format(client.membershipEndDate)}'),
                        ),
                      )),
              ],
            );
          },
        ),
      );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: AppColors.gold),
            const SizedBox(height: 20),
            Text(value, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: AppColors.muted)),
          ]),
        ),
      );
}
