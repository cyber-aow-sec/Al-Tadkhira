import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:al_tadkhira/data/models/zikr.dart';
import 'package:al_tadkhira/presentation/providers/providers.dart';

class AddEditZikrScreen extends ConsumerStatefulWidget {
  final Zikr? zikr;

  const AddEditZikrScreen({super.key, this.zikr});

  @override
  ConsumerState<AddEditZikrScreen> createState() => _AddEditZikrScreenState();
}

class _AddEditZikrScreenState extends ConsumerState<AddEditZikrScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  late TextEditingController _targetController;
  PrayerLink _prayerLink = PrayerLink.none;
  bool _isMandatory = false;
  int _color = 0xFF2196F3;
  bool _autoIncrementAllowed = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.zikr?.title ?? '');
    _noteController = TextEditingController(text: widget.zikr?.note ?? '');
    _targetController = TextEditingController(
      text: widget.zikr?.dailyTarget.toString() == '0'
          ? ''
          : widget.zikr?.dailyTarget.toString() ?? '',
    );
    _prayerLink = widget.zikr?.prayerLink ?? PrayerLink.none;
    _isMandatory = widget.zikr?.isMandatory ?? false;
    _color = widget.zikr?.color ?? 0xFF2196F3;
    _autoIncrementAllowed = widget.zikr?.autoIncrementAllowed ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final zikr = Zikr(
        id: widget.zikr?.id,
        title: _titleController.text,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        dailyTarget: int.tryParse(_targetController.text) ?? 0,
        prayerLink: _prayerLink,
        isMandatory: _isMandatory,
        color: _color,
        autoIncrementAllowed: _autoIncrementAllowed,
        sortOrder: widget.zikr?.sortOrder ?? 0,
      );

      final repository = ref.read(zikrRepositoryProvider);
      if (widget.zikr == null) {
        await repository.create(zikr);
      } else {
        await repository.update(zikr);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.zikr == null ? 'Add Zikr' : 'Edit Zikr'),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _save)],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetController,
              decoration: const InputDecoration(
                labelText: 'Daily Target (Optional)',
                border: OutlineInputBorder(),
                helperText: 'Leave empty for open count',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PrayerLink>(
              initialValue: _prayerLink,
              decoration: const InputDecoration(
                labelText: 'Link to Prayer',
                border: OutlineInputBorder(),
              ),
              items: PrayerLink.values.map((link) {
                return DropdownMenuItem(
                  value: link,
                  child: Text(link.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _prayerLink = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Mandatory'),
              value: _isMandatory,
              onChanged: (value) {
                setState(() {
                  _isMandatory = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Allow Auto-Increment'),
              value: _autoIncrementAllowed,
              onChanged: (value) {
                setState(() {
                  _autoIncrementAllowed = value;
                });
              },
            ),
            // TODO: Color picker
          ],
        ),
      ),
    );
  }
}
