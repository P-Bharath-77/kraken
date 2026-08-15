import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../data/client_repository.dart';
import '../../models/client.dart';
import '../../widgets/client_avatar.dart';
import '../../widgets/empty_state.dart';
import 'client_form_screen.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({required this.repository, required this.client, super.key});
  final ClientRepository repository;
  final Client client;

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  late Client _client;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _client = widget.client;
  }

  Future<void> _edit() async {
    final changed = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => ClientFormScreen(repository: widget.repository, client: _client)));
    if (changed == true) {
      final clients = await widget.repository.getClients();
      if (!mounted) return;
      setState(() {
        _client = clients.firstWhere((c) => c.id == _client.id);
        _changed = true;
      });
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Delete client?'), content: Text('${_client.name} will be removed from this device.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))]));
    if (confirmed != true) return;
    await widget.repository.delete(_client.id!);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 5,
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) Navigator.pop(context, _changed);
          },
          child: Scaffold(
            appBar: AppBar(actions: [IconButton(onPressed: _edit, tooltip: 'Edit client', icon: const Icon(Icons.edit_outlined)), PopupMenuButton<String>(onSelected: (value) { if (value == 'delete') _delete(); }, itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline), SizedBox(width: 10), Text('Delete client')]))])]),
            body: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                child: Column(children: [
                  ClientAvatar(name: _client.name, photoPath: _client.photoPath, radius: 54),
                  const SizedBox(height: 14),
                  Text(_client.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_client.phone, style: const TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 10),
                  Chip(avatar: Icon(_client.membershipActive ? Icons.check_circle_outline : Icons.warning_amber, size: 18), label: Text(_client.membershipActive ? 'ACTIVE MEMBERSHIP' : 'MEMBERSHIP ENDED')),
                ]),
              ),
              const TabBar(isScrollable: true, tabAlignment: TabAlignment.start, tabs: [Tab(text: 'Overview'), Tab(text: 'Progress'), Tab(text: 'Workout'), Tab(text: 'Diet'), Tab(text: 'Payments')]),
              Expanded(child: TabBarView(children: [
                _Overview(client: _client),
                const _ComingSoon(icon: Icons.trending_up, title: 'Progress', message: 'Progress tracking will be added in a later phase.'),
                const _ComingSoon(icon: Icons.fitness_center, title: 'Workout', message: 'Workout management is reserved for a later phase.'),
                _NotesTab(notes: _client.dietNotes),
                _PaymentsTab(client: _client),
              ])),
            ]),
          ),
        ),
      );
}

class _Overview extends StatelessWidget {
  const _Overview({required this.client});
  final Client client;

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
        Row(children: [Expanded(child: _Metric(label: 'Age', value: '${client.age} yrs')), const SizedBox(width: 10), Expanded(child: _Metric(label: 'Height', value: '${_number(client.height)} cm')), const SizedBox(width: 10), Expanded(child: _Metric(label: 'Weight', value: '${_number(client.weight)} kg'))]),
        const SizedBox(height: 16),
        _InfoCard(title: 'Fitness goal', icon: Icons.flag_outlined, body: client.fitnessGoal),
        _InfoCard(title: 'Injuries', icon: Icons.healing_outlined, body: client.injuries),
        _InfoCard(title: 'Membership', icon: Icons.workspace_premium_outlined, body: 'Paid ${DateFormat('dd MMM yyyy').format(client.paymentDate)}\nEnds ${DateFormat('dd MMM yyyy').format(client.membershipEndDate)}'),
      ]);

  String _number(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), child: Column(children: [Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 4), Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12))])));
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.icon, required this.body});
  final String title;
  final IconData icon;
  final String body;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: AppColors.gold), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 7), Text(body, style: const TextStyle(color: AppColors.muted, height: 1.5))]))])));
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => EmptyState(icon: icon, title: '$title ready', message: message);
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({required this.notes});
  final String notes;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [_InfoCard(title: 'Diet notes', icon: Icons.restaurant_outlined, body: notes)]);
}

class _PaymentsTab extends StatelessWidget {
  const _PaymentsTab({required this.client});
  final Client client;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [_InfoCard(title: 'Current membership', icon: Icons.payments_outlined, body: 'Payment date: ${DateFormat('dd MMM yyyy').format(client.paymentDate)}\nMembership ends: ${DateFormat('dd MMM yyyy').format(client.membershipEndDate)}'), const SizedBox(height: 10), const Text('Payment history will be added in a later phase.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted))]);
}
