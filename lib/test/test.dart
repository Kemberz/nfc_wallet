import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nfc_wallet/util/nfc_scanner.dart';
import 'package:nfc_wallet/util/tag_model.dart';
import 'package:nfc_wallet/util/import_export.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Tag> _scannedTags = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tagsJson = prefs.getString('scannedTags');
    if (tagsJson != null) {
      final List<dynamic> tagsList = json.decode(tagsJson);
      setState(() {
        _scannedTags.clear();
        _scannedTags.addAll(tagsList.map((tag) => Tag.fromJson(tag)).toList());
      });
    }
  }

  Future<void> _saveTags() async {
    final prefs = await SharedPreferences.getInstance();
    final String tagsJson = json.encode(_scannedTags.map((tag) => tag.toJson()).toList());
    await prefs.setString('scannedTags', tagsJson);
  }

  void _scanNfc() async {
    final scannedTagId = await scanNfcTag();
    setState(() {
      _scannedTags.add(Tag(
        id: scannedTagId,
        name: 'Unnamed Tag',
        color: Colors.primaries[_scannedTags.length % Colors.primaries.length],
      ));
    });
    _saveTags();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('NFC Scanned'),
          content: const Text('Ready to scan'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showTagDetails(Tag tag) async {
    final TextEditingController nameController = TextEditingController(text: tag.name);
    Color pickerColor = tag.color;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Tag Name'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      tag.image = File(pickedFile.path);
                    });
                  }
                },
                child: tag.image != null
                    ? Image.file(tag.image!, height: 200, width: 200)
                    : const Icon(Icons.image, size: 200),
              ),
              const SizedBox(height: 10),
              Text('Tag ID: ${tag.id}'),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Select Color'),
                        content: SingleChildScrollView(
                          child: BlockPicker(
                            pickerColor: pickerColor,
                            onColorChanged: (Color color) {
                              setState(() {
                                pickerColor = color;
                              });
                            },
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Done'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Pick Color'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  tag.name = nameController.text;
                  tag.color = pickerColor;
                });
                _saveTags();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _replicateNfc(Tag tag) {
    // Implement NFC replication functionality here
    print('Replicating NFC for tag: ${tag.id}');
  }

  void _showImportExportDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Import/Export'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final List<Tag> importedTags = await importTags(context);
                  setState(() {
                    _scannedTags.addAll(importedTags);
                  });
                  _saveTags();
                  Navigator.of(context).pop();
                },
                child: const Text('Import Tags'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await exportTags(_scannedTags, context);
                  Navigator.of(context).pop();
                },
                child: const Text('Export All Tags'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return MultiSelectDialog(
                        tags: _scannedTags,
                        onConfirm: (List<Tag> selectedTags) async {
                          await exportTags(selectedTags, context);
                        },
                      );
                    },
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Export Selected Tags'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 82, 26, 92),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'My Wallet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _scannedTags.length,
              itemBuilder: (context, index) {
                final tag = _scannedTags[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: tag.color,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      title: Text(tag.name, style: const TextStyle(color: Colors.white)),
                      leading: tag.image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(tag.image!, width: 50, height: 50, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.image, size: 50, color: Colors.white),
                      trailing: IconButton(
                        icon: const Icon(Icons.settings_remote_rounded, color: Colors.white),
                        onPressed: () => _replicateNfc(tag),
                      ),
                      onTap: () => _showTagDetails(tag),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: _scanNfc,
              child: const Icon(Icons.add),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton(
              onPressed: _showImportExportDialog,
              child: const Icon(Icons.import_export),
            ),
          ),
        ],
      ),
    );
  }
}

class MultiSelectDialog extends StatefulWidget {
  final List<Tag> tags;
  final Function(List<Tag>) onConfirm;

  const MultiSelectDialog({required this.tags, required this.onConfirm, Key? key}) : super(key: key);

  @override
  State<MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  final List<Tag> _selectedTags = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Tags to Export'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.tags.map((tag) {
            return CheckboxListTile(
              value: _selectedTags.contains(tag),
              onChanged: (bool? selected) {
                setState(() {
                  if (selected == true) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
              title: Text(tag.name),
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onConfirm(_selectedTags);
            Navigator.of(context).pop();
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
