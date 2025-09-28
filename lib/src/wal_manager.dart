import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Manages the Write-Ahead Log (WAL) for database durability.
class WalManager {
  final String _walFilePath;
  IOSink? _walSink;

  WalManager(String dbName)
      : _walFilePath = '$dbName.wal';

  /// Initializes the WAL manager, opening the log file for appending.
  Future<void> open() async {
    final file = File(_walFilePath);
    _walSink = file.openWrite(mode: FileMode.append);
  }

  /// Closes the WAL file.
  Future<void> close() async {
    await _walSink?.close();
    _walSink = null;
  }

  /// Appends an insert operation to the WAL.
  Future<void> logInsert(Map<String, dynamic> document) async {
    final entry = {
      'type': 'insert',
      'timestamp': DateTime.now().toIso8601String(),
      'document': document,
    };
    _walSink?.writeln(jsonEncode(entry));
    await _walSink?.flush(); // Ensure it's written to disk immediately
  }

  /// Appends an update operation to the WAL.
  Future<void> logUpdate(int id, Map<String, dynamic> document) async {
    final entry = {
      'type': 'update',
      'timestamp': DateTime.now().toIso8601String(),
      'id': id,
      'document': document, // The document after update
    };
    _walSink?.writeln(jsonEncode(entry));
    await _walSink?.flush();
  }

  /// Appends a delete operation to the WAL.
  Future<void> logDelete(int id) async {
    final entry = {
      'type': 'delete',
      'timestamp': DateTime.now().toIso8601String(),
      'id': id,
    };
    _walSink?.writeln(jsonEncode(entry));
    await _walSink?.flush();
  }

  /// Reads all entries from the WAL file.
  Stream<Map<String, dynamic>> readAllEntries() async* {
    final file = File(_walFilePath);
    if (!await file.exists()) {
      return;
    }

    await for (final line in file.readAsLines()) {
      if (line.trim().isNotEmpty) {
        yield jsonDecode(line) as Map<String, dynamic>;
      }
    }
  }

  /// Clears the WAL file.
  Future<void> clear() async {
    await close();
    final file = File(_walFilePath);
    if (await file.exists()) {
      await file.delete();
    }
    await open(); // Reopen after clearing
  }
}
