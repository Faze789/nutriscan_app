import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Simple JSON-file-based local storage. Each collection is a separate JSON file.
class LocalDatabase {
  static String? _basePath;

  static Future<String> get _dir async {
    if (_basePath != null) return _basePath!;
    final appDir = await getApplicationDocumentsDirectory();
    _basePath = '${appDir.path}/nutriscan_data';
    final dir = Directory(_basePath!);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return _basePath!;
  }

  static Future<File> _fileFor(String collection) async {
    final dir = await _dir;
    return File('$dir/$collection.json');
  }

  /// Read all items from a collection as a list of maps.
  static Future<List<Map<String, dynamic>>> readAll(String collection) async {
    final file = await _fileFor(collection);
    if (!file.existsSync()) return [];
    final content = await file.readAsString();
    if (content.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(content) as List<dynamic>;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Write all items to a collection (overwrites).
  static Future<void> writeAll(
      String collection, List<Map<String, dynamic>> items) async {
    final file = await _fileFor(collection);
    await file.writeAsString(jsonEncode(items));
  }
}
