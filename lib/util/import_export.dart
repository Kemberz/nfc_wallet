import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'tag_model.dart';
import 'file_utils.dart';

Future<void> exportTags(List<Tag> tags, BuildContext context) async {
  final String tagsJson = json.encode(tags.map((tag) => tag.toJson()).toList());
  final file = await saveToFile(tagsJson, 'tags.json');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Tags exported successfully!')),
  );
  Share.shareXFiles([XFile(file.path)], text: 'Here are my NFC tags');
}

Future<List<Tag>> importTags(BuildContext context) async {
  final String? filePath = await pickFile();
  if (filePath == null) return [];

  final file = File(filePath);
  final String content = await file.readAsString();
  final List<dynamic> tagsList = json.decode(content);
  return tagsList.map((tag) => Tag.fromJson(tag)).toList();
}
