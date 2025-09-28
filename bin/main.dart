import 'dart:io';
import 'package:dart_nosql_database/dart_nosql_database.dart';

/// Simple command-line interface for the Dart NoSQL Database.
void main(List<String> args) async {
  print('🚀 Dart NoSQL Database CLI');
  print('Type "help" for available commands\n');
  
  final db = DartNoSQLDatabase(name: 'cli_db');
  
  while (true) {
    stdout.write('dartdb> ');
    final input = stdin.readLineSync()?.trim();
    
    if (input == null || input.isEmpty) continue;
    
    final parts = input.split(' ');
    final command = parts[0].toLowerCase();
    
    try {
      switch (command) {
        case 'help':
          _showHelp();
          break;
          
        case 'insert':
          await _handleInsert(db, parts);
          break;
          
        case 'find':
          await _handleFind(db, parts);
          break;
          
        case 'count':
          await _handleCount(db);
          break;
          
        case 'update':
          await _handleUpdate(db, parts);
          break;
          
        case 'delete':
          await _handleDelete(db, parts);
          break;
          
        case 'clear':
          await db.clear();
          print('✅ Database cleared');
          break;
          
        case 'stats':
          await _handleStats(db);
          break;
          
        case 'index':
          await _handleIndex(db, parts);
          break;
          
        case 'save':
          await _handleSave(db, parts);
          break;
          
        case 'load':
          await _handleLoad(db, parts);
          break;
          
        case 'exit':
        case 'quit':
          print('👋 Goodbye!');
          return;
          
        default:
          print('❌ Unknown command: $command');
          print('Type "help" for available commands');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }
}

void _showHelp() {
  print('''
📚 Available Commands:

📝 Data Operations:
  insert <json>           - Insert a document (e.g., insert {"name":"John","age":25})
  find [query]            - Find documents (e.g., find name==John, find age>25)
  count                   - Count all documents
  update <query> <json>   - Update documents (e.g., update name==John {"age":26})
  delete <query>          - Delete documents (e.g., delete age<25)
  clear                   - Clear all documents

🔧 Database Management:
  stats                   - Show database statistics
  index create <field>    - Create an index on a field
  index drop <field>      - Drop an index
  index list              - List all indexes

💾 Persistence:
  save <filename>         - Save database to file
  load <filename>         - Load database from file

🚪 General:
  help                    - Show this help message
  exit, quit              - Exit the program

💡 Query Syntax:
  Simple queries: field==value, field!=value, field>value, field<value
  Example: find age>25, find name==John, find city!=New York
  ''');
}

Future<void> _handleInsert(DartNoSQLDatabase db, List<String> parts) async {
  if (parts.length < 2) {
    print('❌ Usage: insert <json>');
    return;
  }
  
  final jsonStr = parts.skip(1).join(' ');
  try {
    final doc = _parseSimpleJson(jsonStr);
    final result = await db.insert(doc);
    print('✅ Inserted document with ID: ${result['_id']}');
  } catch (e) {
    print('❌ Invalid JSON: $e');
  }
}

Future<void> _handleFind(DartNoSQLDatabase db, List<String> parts) async {
  try {
    if (parts.length == 1) {
      // Find all
      final results = await db.findAll();
      _printResults(results);
    } else {
      // Find with query
      final queryStr = parts.skip(1).join(' ');
      final results = await _executeQuery(db, queryStr);
      _printResults(results);
    }
  } catch (e) {
    print('❌ Query error: $e');
  }
}

Future<void> _handleCount(DartNoSQLDatabase db) async {
  final count = await db.count();
  print('📊 Total documents: $count');
}

Future<void> _handleUpdate(DartNoSQLDatabase db, List<String> parts) async {
  if (parts.length < 3) {
    print('❌ Usage: update <query> <json>');
    return;
  }
  
  try {
    final queryStr = parts[1];
    final jsonStr = parts.skip(2).join(' ');
    final updateData = _parseSimpleJson(jsonStr);
    
    final updated = await _executeUpdate(db, queryStr, updateData);
    print('✅ Updated $updated document(s)');
  } catch (e) {
    print('❌ Update error: $e');
  }
}

Future<void> _handleDelete(DartNoSQLDatabase db, List<String> parts) async {
  if (parts.length < 2) {
    print('❌ Usage: delete <query>');
    return;
  }
  
  try {
    final queryStr = parts.skip(1).join(' ');
    final deleted = await _executeDelete(db, queryStr);
    print('🗑️  Deleted $document(s)');
  } catch (e) {
    print('❌ Delete error: $e');
  }
}

Future<void> _handleStats(DartNoSQLDatabase db) async {
  final stats = await db.getStats();
  print('📋 Database Statistics:');
  print('   Name: ${stats['name']}');
  print('   Documents: ${stats['documentCount']}');
  print('   Indexes: ${stats['indexes'].length}');
  if (stats['indexes'].isNotEmpty) {
    print('   Index fields: ${stats['indexes'].keys.join(', ')}');
  }
}

Future<void> _handleIndex(DartNoSQLDatabase db, List<String> parts) async {
  if (parts.length < 2) {
    print('❌ Usage: index <create|drop|list> [field]');
    return;
  }
  
  final action = parts[1].toLowerCase();
  
  switch (action) {
    case 'create':
      if (parts.length < 3) {
        print('❌ Usage: index create <field>');
        return;
      }
      await db.createIndex(parts[2]);
      print('✅ Created index on field: ${parts[2]}');
      break;
      
    case 'drop':
      if (parts.length < 3) {
        print('❌ Usage: index drop <field>');
        return;
      }
      await db.dropIndex(parts[2]);
      print('🗑️  Dropped index on field: ${parts[2]}');
      break;
      
    case 'list':
      final info = await db.getIndexInfo();
      if (info.isEmpty) {
        print('📋 No indexes found');
      } else {
        print('📋 Indexes:');
        info.forEach((field, details) {
          print('   - $field (${details['type']})');
        });
      }
      break;
      
    default:
      print('❌ Unknown index command: $action');
  }
}

Future<void> _handleSave(DartNoSQLDatabase db, List<String> parts) async {
  if (parts.length < 2) {
    print('❌ Usage: save <filename>');
    return;
  }
  
  final filename = parts[1];
  await db.saveToFile(filename);
  print('💾 Database saved to: $filename.ddb');
}

Future<void> _handleLoad(DartNoSQLDatabase db, List<String> parts) async {
  if (parts.length < 2) {
    print('❌ Usage: load <filename>');
    return;
  }
  
  final filename = parts[1];
  await db.loadFromFile(filename);
  print('📂 Database loaded from: $filename.ddb');
}

Map<String, dynamic> _parseSimpleJson(String jsonStr) {
  // Simple JSON parser for CLI usage
  jsonStr = jsonStr.trim();
  if (!jsonStr.startsWith('{') || !jsonStr.endsWith('}')) {
    throw FormatException('JSON must start with { and end with }');
  }
  
  final content = jsonStr.substring(1, jsonStr.length - 1);
  final result = <String, dynamic>{};
  
  final pairs = content.split(',');
  for (final pair in pairs) {
    final keyValue = pair.split(':');
    if (keyValue.length == 2) {
      final key = keyValue[0].trim().replaceAll('"', '').replaceAll("'", '');
      var value = keyValue[1].trim();
      
      // Parse value
      if (value == 'true') {
        result[key] = true;
      } else if (value == 'false') {
        result[key] = false;
      } else if (value == 'null') {
        result[key] = null;
      } else if (value.startsWith('"') && value.endsWith('"')) {
        result[key] = value.substring(1, value.length - 1);
      } else if (value.startsWith("'") && value.endsWith("'")) {
        result[key] = value.substring(1, value.length - 1);
      } else {
        final numValue = num.tryParse(value);
        result[key] = numValue ?? value;
      }
    }
  }
  
  return result;
}

Future<List<Map<String, dynamic>>> _executeQuery(
    DartNoSQLDatabase db, String queryStr) async {
  
  // Simple query parser
  if (queryStr.contains('==')) {
    final parts = queryStr.split('==');
    final field = parts[0].trim();
    final value = parts[1].trim();
    final parsedValue = _parseValue(value);
    
    return await db.query((doc) => doc[field] == parsedValue);
  } else if (queryStr.contains('!=')) {
    final parts = queryStr.split('!=');
    final field = parts[0].trim();
    final value = parts[1].trim();
    final parsedValue = _parseValue(value);
    
    return await db.query((doc) => doc[field] != parsedValue);
  } else if (queryStr.contains('>')) {
    final parts = queryStr.split('>');
    final field = parts[0].trim();
    final value = num.parse(parts[1].trim());
    
    return await db.query((doc) => (doc[field] as num) > value);
  } else if (queryStr.contains('<')) {
    final parts = queryStr.split('<');
    final field = parts[0].trim();
    final value = num.parse(parts[1].trim());
    
    return await db.query((doc) => (doc[field] as num) < value);
  } else {
    throw FormatException('Unsupported query format');
  }
}

Future<int> _executeUpdate(DartNoSQLDatabase db, String queryStr,
    Map<String, dynamic> updateData) async {
  
  // Simple query parser for updates
  if (queryStr.contains('==')) {
    final parts = queryStr.split('==');
    final field = parts[0].trim();
    final value = parts[1].trim();
    final parsedValue = _parseValue(value);
    
    return await db.update((doc) => doc[field] == parsedValue, updateData);
  } else {
    throw FormatException('Unsupported query format for update');
  }
}

Future<int> _executeDelete(DartNoSQLDatabase db, String queryStr) async {
  // Simple query parser for deletes
  if (queryStr.contains('==')) {
    final parts = queryStr.split('==');
    final field = parts[0].trim();
    final value = parts[1].trim();
    final parsedValue = _parseValue(value);
    
    return await db.delete((doc) => doc[field] == parsedValue);
  } else if (queryStr.contains('<')) {
    final parts = queryStr.split('<');
    final field = parts[0].trim();
    final value = num.parse(parts[1].trim());
    
    return await db.delete((doc) => (doc[field] as num) < value);
  } else {
    throw FormatException('Unsupported query format for delete');
  }
}

dynamic _parseValue(String value) {
  value = value.trim();
  if (value == 'true') return true;
  if (value == 'false') return false;
  if (value == 'null') return null;
  if (value.startsWith('"') && value.endsWith('"')) {
    return value.substring(1, value.length - 1);
  }
  if (value.startsWith("'") && value.endsWith("'")) {
    return value.substring(1, value.length - 1);
  }
  
  final numValue = num.tryParse(value);
  return numValue ?? value;
}

void _printResults(List<Map<String, dynamic>> results) {
  if (results.isEmpty) {
    print('📭 No documents found');
    return;
  }
  
  print('📋 Found ${results.length} document(s):');
  for (final doc in results) {
    print('   ${doc.toString()}');
  }
}