import 'package:dnd_gym/data/memory_client_repository.dart';
import 'package:dnd_gym/models/client.dart';
import 'package:flutter_test/flutter_test.dart';

Client sample({String name = 'Asha Rao'}) => Client(
      name: name,
      phone: '9876543210',
      age: 28,
      height: 165,
      weight: 62,
      injuries: 'None',
      dietNotes: 'High protein',
      fitnessGoal: 'Strength',
      paymentDate: DateTime(2026, 8, 1),
      membershipEndDate: DateTime(2026, 9, 1),
    );

void main() {
  test('client map round trip preserves data', () {
    final original = sample().copyWith(id: 7);
    final restored = Client.fromMap(original.toMap());
    expect(restored.id, 7);
    expect(restored.name, original.name);
    expect(restored.fitnessGoal, 'Strength');
  });

  test('memory repository saves, searches, and deletes clients', () async {
    final repository = MemoryClientRepository();
    final saved = await repository.save(sample());
    await repository.save(sample(name: 'Vikram Singh'));
    expect(await repository.getClients(query: 'Asha'), hasLength(1));
    await repository.delete(saved.id!);
    expect(await repository.getClients(), hasLength(1));
  });
}
