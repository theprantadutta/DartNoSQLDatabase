import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Handles persistent storage operations for the database.
class StorageEngine {
  static const String _defaultFileExtension = '.ddb';
  static const String _metadataFileExtension = '.meta';
  
  /// Saves the database to a file.
  /// 
  /// [documents] - The list of documents to save.
  /// [filePath] - The path to save the database file.
  Future<void> saveToFile(
      List<Map<String, dynamic>> documents, String filePath) async {
    
    try {
      // Ensure file has the correct extension
      if (!filePath.endsWith(_defaultFileExtension)) {
        filePath += _defaultFileExtension;
      }
      
      final file = File(filePath);
      final directory = file.parent;
      
      // Create directory if it doesn't exist
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      // Convert documents to JSON
      final jsonData = jsonEncode({
        'version': '1.0.0',
        'timestamp': DateTime.now().toIso8601String(),
        'document_count': documents.length,
        'documents': documents,
      });
      
      // Write to file
      await file.writeAsString(jsonData, flush: true);
      
      // Save metadata separately
      await _saveMetadata(filePath, documents.length);
      
    } catch (e) {
      throw Exception('Failed to save database to file: $e');
    }
  }

  /// Loads the database from a file.
  /// 
  /// [filePath] - The path to load the database file from.
  /// Returns a list of loaded documents.
  Future<List<Map<String, dynamic>>> loadFromFile(String filePath) async {
    try {
      // Try with extension first, then without
      String fullPath = filePath;
      if (!filePath.endsWith(_defaultFileExtension)) {
        fullPath = filePath + _defaultFileExtension;
      }
      
      final file = File(fullPath);
      
      // Check if file exists
      if (!await file.exists()) {
        // Try without extension
        final altFile = File(filePath);
        if (await altFile.exists()) {
          return await _loadFromFileInternal(altFile);
        }
        throw FileSystemException('Database file not found', filePath);
      }
      
      return await _loadFromFileInternal(file);
      
    } catch (e) {
      throw Exception('Failed to load database from file: $e');
    }
  }

  /// Internal method to load documents from a file.
  Future<List<Map<String, dynamic>>> _loadFromFileInternal(File file) async {
    final jsonData = await file.readAsString();
    final data = jsonDecode(jsonData) as Map<String, dynamic>;
    
    // Validate file format
    if (!data.containsKey('documents') || !data.containsKey('version')) {
      throw FormatException('Invalid database file format');
    }
    
    final documents = List<Map<String, dynamic>>.from(data['documents']);
    
    // Validate document structure
    for (final doc in documents) {
      if (doc is! Map<String, dynamic>) {
        throw FormatException('Invalid document format in database file');
      }
    }
    
    return documents;
  }

  /// Saves metadata about the database.
  /// 
  /// [filePath] - The path to the main database file.
  /// [documentCount] - The number of documents in the database.
  Future<void> _saveMetadata(String filePath, int documentCount) async {
    final metadataFilePath = filePath.replaceAll(
        _defaultFileExtension, _metadataFileExtension);
    
    final metadata = {
      'version': '1.0.0',
      'timestamp': DateTime.now().toIso8601String(),
      'document_count': documentCount,
      'file_size': await File(filePath).length(),
      'checksum': await _calculateChecksum(filePath),
    };
    
    final metadataFile = File(metadataFilePath);
    await metadataFile.writeAsString(jsonEncode(metadata));
  }

  /// Calculates a checksum for a file.
  /// 
  /// [filePath] - The path to the file.
  /// Returns the checksum as a hex string.
  Future<String> _calculateChecksum(String filePath) async {
    // Simplified checksum - in production, use a proper hash function
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    
    int checksum = 0;
    for (final byte in bytes) {
      checksum = (checksum + byte) & 0xFFFFFFFF;
    }
    
    return checksum.toRadixString(16).padLeft(8, '0');
  }

  /// Exports the database to different formats.
  /// 
  /// [documents] - The documents to export.
  /// [filePath] - The path to export to.
  /// [format] - The export format ('json', 'csv', 'xml').
  Future<void> export(
      List<Map<String, dynamic>> documents,
      String filePath,
      String format) async {
    
    switch (format.toLowerCase()) {
      case 'json':
        await _exportToJson(documents, filePath);
        break;
      case 'csv':
        await _exportToCsv(documents, filePath);
        break;
      case 'xml':
        await _exportToXml(documents, filePath);
        break;
      default:
        throw ArgumentError('Unsupported export format: $format');
    }
  }

  /// Exports documents to JSON format.
  Future<void> _exportToJson(
      List<Map<String, dynamic>> documents, String filePath) async {
    
    final jsonData = jsonEncode(documents);
    await File(filePath).writeAsString(jsonData);
  }

  /// Exports documents to CSV format.
  Future<void> _exportToCsv(
      List<Map<String, dynamic>> documents, String filePath) async {
    
    if (documents.isEmpty) {
      await File(filePath).writeAsString('');
      return;
    }
    
    // Get all unique field names
    final fieldNames = <String>{};
    for (final doc in documents) {
      fieldNames.addAll(doc.keys);
    }
    
    final sortedFields = fieldNames.toList()..sort();
    
    // Create CSV content
    final csvLines = <String>[];
    
    // Header row
    csvLines.add(sortedFields.join(','));
    
    // Data rows
    for (final doc in documents) {
      final values = sortedFields.map((field) {
        final value = doc[field];
        if (value == null) return '';
        
        // Handle strings with commas by quoting
        final stringValue = value.toString();
        if (stringValue.contains(',')) {
          return '"$stringValue"';
        }
        return stringValue;
      });
      
      csvLines.add(values.join(','));
    }
    
    await File(filePath).writeAsString(csvLines.join('\n'));
  }

  /// Exports documents to XML format.
  Future<void> _exportToXml(
      List<Map<String, dynamic>> documents, String filePath) async {
    
    final xmlLines = <String>[
      '<?xml version="1.0" encoding="UTF-8"?>',
      '<database>',
    ];
    
    for (final doc in documents) {
      xmlLines.add('  <document>');
      
      for (final entry in doc.entries) {
        final key = _escapeXml(entry.key);
        final value = _escapeXml(entry.value.toString());
        xmlLines.add('    <$key>$value</$key>');
      }
      
      xmlLines.add('  </document>');
    }
    
    xmlLines.add('</database>');
    
    await File(filePath).writeAsString(xmlLines.join('\n'));
  }

  /// Escapes special XML characters.
  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  /// Imports data from various formats.
  /// 
  /// [filePath] - The path to import from.
  /// [format] - The import format ('json', 'csv').
  /// Returns a list of imported documents.
  Future<List<Map<String, dynamic>>> import(String filePath, String format) async {
    switch (format.toLowerCase()) {
      case 'json':
        return await _importFromJson(filePath);
      case 'csv':
        return await _importFromCsv(filePath);
      default:
        throw ArgumentError('Unsupported import format: $format');
    }
  }

  /// Imports documents from JSON format.
  Future<List<Map<String, dynamic>>> _importFromJson(String filePath) async {
    final jsonData = await File(filePath).readAsString();
    final data = jsonDecode(jsonData);
    
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    } else if (data is Map) {
      return [Map<String, dynamic>.from(data)];
    } else {
      throw FormatException('Invalid JSON format for import');
    }
  }

  /// Imports documents from CSV format.
  Future<List<Map<String, dynamic>>> _importFromCsv(String filePath) async {
    final csvData = await File(filePath).readAsString();
    final lines = csvData.split('\n');
    
    if (lines.isEmpty) {
      return [];
    }
    
    final headers = lines[0].split(',');
    final documents = <Map<String, dynamic>>[];
    
    for (int i = 1; i < lines.length; i++) {
      if (lines[i].trim().isEmpty) continue;
      
      final values = _parseCsvLine(lines[i]);
      final doc = <String, dynamic>{};
      
      for (int j = 0; j < headers.length && j < values.length; j++) {
        doc[headers[j]] = values[j];
      }
      
      documents.add(doc);
    }
    
    return documents;
  }

  /// Parses a CSV line handling quoted values.
  List<String> _parseCsvLine(String line) {
    final values = <String>[];
    var current = '';
    var inQuotes = false;
    
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        values.add(current);
        current = '';
      } else {
        current += char;
      }
    }
    
    values.add(current);
    return values;
  }

  /// Gets file information for the database file.
  /// 
  /// [filePath] - The path to the database file.
  /// Returns a map with file information.
  Future<Map<String, dynamic>> getFileInfo(String filePath) async {
    final file = File(filePath);
    
    if (!await file.exists()) {
      throw FileSystemException('Database file not found', filePath);
    }
    
    final stat = await file.stat();
    
    return {
      'path': filePath,
      'size': stat.size,
      'modified': stat.modified.toIso8601String(),
      'created': stat.changed.toIso8601String(),
      'exists': true,
    };
  }
}