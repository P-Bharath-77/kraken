import 'package:flutter/material.dart';

import '../../data/client_repository.dart';
import '../clients/client_list_screen.dart';
import '../dashboard/dashboard_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({required this.repository, super.key});
  final ClientRepository repository;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  int _refreshKey = 0;

  void _refresh() => setState(() => _refreshKey++);

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(key: ValueKey('dashboard-$_refreshKey'), repository: widget.repository, onOpenClients: () => setState(() => _index = 1)),
      ClientListScreen(repository: widget.repository, onChanged: _refresh),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Clients'),
        ],
      ),
    );
  }
}
