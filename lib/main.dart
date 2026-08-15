import 'package:flutter/material.dart';

import 'app.dart';
import 'data/client_repository.dart';
import 'data/local_client_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = LocalClientRepository();
  await repository.initialize();
  runApp(DndGymApp(repository: repository));
}
