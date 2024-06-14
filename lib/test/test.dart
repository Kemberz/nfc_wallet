import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nfc_wallet/util/nfc_scanner.dart';
import 'package:nfc_wallet/util/tag_model.dart';

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

  void _scanNfc() async {
    final scannedTagId = await scanNfcTag();
    setState(() {
      _scannedTags.add(Tag(id: scannedTagId, name: 'Unnamed Tag', color: Colors.black));
    });

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
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  tag.name = nameController.text;
                });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'My Wallet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _scannedTags.length,
              itemBuilder: (context, index) {
                final tag = _scannedTags[index];
                return ListTile(
                  title: Text(tag.name),
                  leading: tag.image != null
                      ? Image.file(tag.image!, width: 50, height: 50)
                      : const Icon(Icons.image, size: 50),
                  onTap: () => _showTagDetails(tag),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanNfc,
        child: const Icon(Icons.nfc),
      ),
    );
  }
}
