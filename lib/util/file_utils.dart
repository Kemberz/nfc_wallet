// util/file_utils.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

Future<File> _getLocalFile(String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/$fileName');
}

Future<String?> pickFile() async {
  final result = await FilePicker.platform.pickFiles();
  return result?.files.single.path;
}

Future<File> saveToFile(String content, String fileName) async {
  final file = await _getLocalFile(fileName);
  await file.writeAsString(content);
  return file;
}

Future<String> readFromFile(String fileName) async {
  try {
    final file = await _getLocalFile(fileName);
    return await file.readAsString();
  } catch (e) {
    return '';
  }
}
