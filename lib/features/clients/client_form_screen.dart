import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../core/theme.dart';
import '../../data/client_repository.dart';
import '../../models/client.dart';
import '../../widgets/client_avatar.dart';

class ClientFormScreen extends StatefulWidget {
  const ClientFormScreen({required this.repository, this.client, super.key});
  final ClientRepository repository;
  final Client? client;

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _fields;
  late DateTime _paymentDate;
  late DateTime _endDate;
  String? _photoPath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.client;
    _fields = {
      'name': TextEditingController(text: c?.name),
      'phone': TextEditingController(text: c?.phone),
      'age': TextEditingController(text: c?.age.toString()),
      'height': TextEditingController(text: c?.height.toString()),
      'weight': TextEditingController(text: c?.weight.toString()),
      'injuries': TextEditingController(text: c?.injuries),
      'diet': TextEditingController(text: c?.dietNotes),
      'goal': TextEditingController(text: c?.fitnessGoal),
    };
    _paymentDate = c?.paymentDate ?? DateTime.now();
    _endDate = c?.membershipEndDate ?? DateTime.now().add(const Duration(days: 30));
    _photoPath = c?.photoPath;
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Required' : null;

  Future<void> _pickPhoto() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 82, maxWidth: 1200);
    if (image == null) return;
    final directory = await getApplicationDocumentsDirectory();
    final photos = Directory(path.join(directory.path, 'client_photos'));
    await photos.create(recursive: true);
    final saved = await File(image.path).copy(path.join(photos.path, '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}'));
    setState(() => _photoPath = saved.path);
  }

  Future<void> _chooseDate(bool payment) async {
    final selected = await showDatePicker(context: context, initialDate: payment ? _paymentDate : _endDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (selected != null) setState(() => payment ? _paymentDate = selected : _endDate = selected);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final client = Client(
      id: widget.client?.id,
      name: _fields['name']!.text.trim(),
      phone: _fields['phone']!.text.trim(),
      age: int.parse(_fields['age']!.text),
      height: double.parse(_fields['height']!.text),
      weight: double.parse(_fields['weight']!.text),
      injuries: _fields['injuries']!.text.trim(),
      dietNotes: _fields['diet']!.text.trim(),
      fitnessGoal: _fields['goal']!.text.trim(),
      paymentDate: _paymentDate,
      membershipEndDate: _endDate,
      photoPath: _photoPath,
    );
    await widget.repository.save(client);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.client == null ? 'Add client' : 'Edit client')),
        body: Form(
          key: _formKey,
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 36), children: [
            Center(child: Stack(children: [
              ClientAvatar(name: _fields['name']!.text, photoPath: _photoPath, radius: 52),
              Positioned(right: 0, bottom: 0, child: IconButton.filled(onPressed: _pickPhoto, icon: const Icon(Icons.camera_alt_outlined))),
            ])),
            const SizedBox(height: 28),
            _Section(title: 'Personal information', children: [
              _input('name', 'Full name', Icons.person_outline),
              _input('phone', 'Phone number', Icons.phone_outlined, keyboard: TextInputType.phone),
              Row(children: [Expanded(child: _input('age', 'Age', Icons.cake_outlined, keyboard: TextInputType.number)), const SizedBox(width: 12), Expanded(child: _input('height', 'Height (cm)', Icons.height, keyboard: const TextInputType.numberWithOptions(decimal: true)))]),
              _input('weight', 'Weight (kg)', Icons.monitor_weight_outlined, keyboard: const TextInputType.numberWithOptions(decimal: true)),
            ]),
            _Section(title: 'Health & goals', children: [
              _input('goal', 'Fitness goal', Icons.flag_outlined),
              _input('injuries', 'Injuries (write None if not applicable)', Icons.healing_outlined, lines: 2),
              _input('diet', 'Diet notes', Icons.restaurant_outlined, lines: 3),
            ]),
            _Section(title: 'Membership', children: [
              _dateTile('Payment date', _paymentDate, () => _chooseDate(true)),
              _dateTile('Membership end date', _endDate, () => _chooseDate(false)),
            ]),
            const SizedBox(height: 12),
            FilledButton.icon(onPressed: _saving ? null : _save, icon: _saving ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined), label: Text(widget.client == null ? 'Add client' : 'Save changes'), style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54))),
          ]),
        ),
      );

  Widget _input(String key, String label, IconData icon, {TextInputType? keyboard, int lines = 1}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: _fields[key],
          keyboardType: keyboard,
          maxLines: lines,
          validator: (value) {
            final required = _required(value);
            if (required != null) return required;
            if (['age', 'height', 'weight'].contains(key) && double.tryParse(value!) == null) return 'Enter a valid number';
            return null;
          },
          decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        ),
      );

  Widget _dateTile(String label, DateTime value, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ListTile(onTap: onTap, tileColor: AppColors.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), leading: const Icon(Icons.calendar_month_outlined), title: Text(label), subtitle: Text(DateFormat('dd MMM yyyy').format(value)), trailing: const Icon(Icons.edit_calendar_outlined)),
      );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold))),
          ...children,
        ]),
      );
}
