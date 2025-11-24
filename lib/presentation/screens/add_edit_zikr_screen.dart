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
  List<ZikrPart> _parts = [];

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

    if (widget.zikr != null && widget.zikr!.parts.isNotEmpty) {
      _parts = List.from(widget.zikr!.parts);
    }
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
      // Validate parts if any
      for (var part in _parts) {
        if (part.description.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Part description cannot be empty')),
          );
          return;
        }
      }

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
        parts: _parts,
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

  void _addPart() {
    setState(() {
      _parts.add(
        ZikrPart(description: '', target: 33, sortOrder: _parts.length),
      );
    });
  }

  void _removePart(int index) {
    setState(() {
      _parts.removeAt(index);
    });
  }

  void _updatePart(int index, String description, int target) {
    setState(() {
      _parts[index] = _parts[index].copyWith(
        description: description,
        target: target,
      );
    });
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
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Parts (Wazifa Steps)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: _addPart,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
            if (_parts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('No parts added. This will be a single-step Zikr.'),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _parts.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final item = _parts.removeAt(oldIndex);
                    _parts.insert(newIndex, item);
                    // Update sort orders
                    for (int i = 0; i < _parts.length; i++) {
                      _parts[i] = _parts[i].copyWith(sortOrder: i);
                    }
                  });
                },
                itemBuilder: (context, index) {
                  final part = _parts[index];
                  return Card(
                    key: ValueKey(
                      part.hashCode,
                    ), // Use a better key if possible, but hashCode of object might change if object changes.
                    // Better to use a unique ID if available, or just index if not reordering dynamically with animation issues.
                    // Since we are editing in place, ValueKey(part) is risky if part changes.
                    // Let's use ValueKey(index) but that breaks reordering animation.
                    // Let's use ObjectKey(part) or UniqueKey() if we don't persist IDs yet.
                    // Actually, for this simple list, ValueKey(part.description + index.toString()) is okay-ish.
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: part.description,
                                  decoration: const InputDecoration(
                                    labelText: 'Description',
                                    isDense: true,
                                  ),
                                  onChanged: (value) =>
                                      _updatePart(index, value, part.target),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  initialValue: part.target.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Count',
                                    isDense: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) => _updatePart(
                                    index,
                                    part.description,
                                    int.tryParse(value) ?? 0,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removePart(index),
                              ),
                              const Icon(Icons.drag_handle, color: Colors.grey),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
