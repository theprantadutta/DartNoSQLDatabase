import 'dart:async';

import 'query_engine.dart';
import 'index_manager.dart';
import 'storage_engine.dart';

/// Main database class that provides the NoSQL document database functionality.
class DartNoSQLDatabase {
  final String _name;
  final List<Map<String, dynamic>> _documents;
  final QueryEngine _queryEngine;
  final IndexManager _indexManager;
  final StorageEngine _storageEngine;
  int _nextId = 1;

  /// Creates a new database instance.
  /// 
  /// [name] - Optional name for the database
  DartNoSQLDatabase({String name = 'default'})
      : _name = name,
        _documents = [],
        _queryEngine = QueryEngine(),
        _indexManager = IndexManager(),
        _storageEngine = StorageEngine();

  /// Inserts a document into the database.
  /// 
  /// [document] - The document to insert. Must be a Map.
  /// Returns the inserted document with an auto-generated _id field.
  Future<Map<String, dynamic>> insert(Map<String, dynamic> document) async {
    

    // Create a copy to avoid modifying the original
    final doc = Map<String, dynamic>.from(document);
    
    // Add auto-generated ID if not present
    if (!doc.containsKey('_id')) {
      doc['_id'] = _nextId++;
    }
    
    // Add timestamp metadata
    doc['_createdAt'] = DateTime.now().toIso8601String();
    doc['_updatedAt'] = DateTime.now().toIso8601String();
    
    _documents.add(doc);
    
    // Update indexes
    await _indexManager.addToIndexes(doc);
    
    return doc;
  }

  /// Inserts multiple documents into the database.
  /// 
  /// [documents] - List of documents to insert.
  /// Returns the inserted documents with auto-generated _id fields.
  Future<List<Map<String, dynamic>>> insertMany(
      List<Map<String, dynamic>> documents) async {
    final insertedDocs = <Map<String, dynamic>>[];
    
    for (final doc in documents) {
      final inserted = await insert(doc);
      insertedDocs.add(inserted);
    }
    
    return insertedDocs;
  }

  /// Queries documents using a Dart function predicate.
  /// 
  /// [predicate] - A function that takes a document and returns true if it matches.
  /// Returns a list of matching documents.
  Future<List<Map<String, dynamic>>> query(
      bool Function(Map<String, dynamic>) predicate) async {

    return _queryEngine.execute(_documents, predicate);
  }

  /// Finds one document matching the predicate.
  /// 
  /// [predicate] - A function that takes a document and returns true if it matches.
  /// Returns the first matching document, or null if none found.
  Future<Map<String, dynamic>?> findOne(
      bool Function(Map<String, dynamic>) predicate) async {
    final results = await query(predicate);
    return results.isEmpty ? null : results.first;
  }

  /// Updates documents matching the predicate.
  /// 
  /// [predicate] - A function that identifies documents to update.
  /// [updateData] - The data to merge into matching documents.
  /// Returns the number of documents updated.
  Future<int> update(bool Function(Map<String, dynamic>) predicate,
      Map<String, dynamic> updateData) async {

    int updatedCount = 0;
    
    for (int i = 0; i < _documents.length; i++) {
      if (predicate(_documents[i])) {
        // Remove from indexes before update
        await _indexManager.removeFromIndexes(_documents[i]);
        
        // Update the document
        _documents[i].addAll(updateData);
        _documents[i]['_updatedAt'] = DateTime.now().toIso8601String();
        
        // Add back to indexes
        await _indexManager.addToIndexes(_documents[i]);
        
        updatedCount++;
      }
    }
    
    return updatedCount;
  }

  /// Updates one document matching the predicate.
  /// 
  /// [predicate] - A function that identifies the document to update.
  /// [updateData] - The data to merge into the matching document.
  /// Returns true if a document was updated, false otherwise.
  Future<bool> updateOne(bool Function(Map<String, dynamic>) predicate,
      Map<String, dynamic> updateData) async {

    for (int i = 0; i < _documents.length; i++) {
      if (predicate(_documents[i])) {
        // Remove from indexes before update
        await _indexManager.removeFromIndexes(_documents[i]);
        
        // Update the document
        _documents[i].addAll(updateData);
        _documents[i]['_updatedAt'] = DateTime.now().toIso8601String();
        
        // Add back to indexes
        await _indexManager.addToIndexes(_documents[i]);
        
        return true;
      }
    }
    
    return false;
  }

  /// Deletes documents matching the predicate.
  /// 
  /// [predicate] - A function that identifies documents to delete.
  /// Returns the number of documents deleted.
  Future<int> delete(bool Function(Map<String, dynamic>) predicate) async {

    int initialLength = _documents.length;
    
    // Remove documents that match the predicate
    final documentsToKeep = <Map<String, dynamic>>[];
    final documentsToDelete = <Map<String, dynamic>>[];
    
    for (final doc in _documents) {
      if (predicate(doc)) {
        documentsToDelete.add(doc);
      } else {
        documentsToKeep.add(doc);
      }
    }
    
    // Remove from indexes
    for (final doc in documentsToDelete) {
      await _indexManager.removeFromIndexes(doc);
    }
    
    _documents.clear();
    _documents.addAll(documentsToKeep);
    
    return initialLength - _documents.length;
  }

  /// Deletes one document matching the predicate.
  /// 
  /// [predicate] - A function that identifies the document to delete.
  /// Returns true if a document was deleted, false otherwise.
  Future<bool> deleteOne(bool Function(Map<String, dynamic>) predicate) async {

    for (int i = 0; i < _documents.length; i++) {
      if (predicate(_documents[i])) {
        // Remove from indexes
        await _indexManager.removeFromIndexes(_documents[i]);
        
        // Remove the document
        _documents.removeAt(i);
        return true;
      }
    }
    
    return false;
  }

  /// Counts documents, optionally matching a predicate.
  /// 
  /// [predicate] - Optional function to filter documents to count.
  /// Returns the count of matching documents.
  Future<int> count([bool Function(Map<String, dynamic>)? predicate]) async {
    if (predicate == null) {
      return _documents.length;
    }
    
    return _documents.where(predicate).length;
  }

  /// Gets all documents in the database.
  /// 
  /// Returns a list of all documents.
  Future<List<Map<String, dynamic>>> findAll() async {
    return List<Map<String, dynamic>>.from(_documents);
  }

  /// Clears all documents from the database.
  Future<void> clear() async {
    _documents.clear();
    await _indexManager.clearAllIndexes();
    _nextId = 1;
  }

  /// Creates an index on a field for faster queries.
  /// 
  /// [field] - The field name to index.
  Future<void> createIndex(String field) async {
    await _indexManager.createIndex(field, _documents);
  }

  /// Drops an index on a field.
  /// 
  /// [field] - The field name to remove the index from.
  Future<void> dropIndex(String field) async {
    await _indexManager.dropIndex(field);
  }

  /// Gets information about all indexes.
  Future<Map<String, dynamic>> getIndexInfo() async {
    return _indexManager.getIndexInfo();
  }

  /// Saves the database to a file.
  /// 
  /// [filePath] - The path to save the database file.
  Future<void> saveToFile(String filePath) async {
    await _storageEngine.saveToFile(_documents, filePath);
  }

  /// Loads the database from a file.
  /// 
  /// [filePath] - The path to load the database file from.
  Future<void> loadFromFile(String filePath) async {
    final loadedDocs = await _storageEngine.loadFromFile(filePath);
    await clear();
    
    for (final doc in loadedDocs) {
      await insert(doc);
    }
  }

  /// Gets database statistics.
  Future<Map<String, dynamic>> getStats() async {
    return {
      'name': _name,
      'documentCount': _documents.length,
      'indexes': await getIndexInfo(),
      'totalSize': _documents.length, // Approximate document count
    };
  }

  /// Performs aggregation operations.
  /// 
  /// [pipeline] - A list of aggregation stages.
  Future<List<Map<String, dynamic>>> aggregate(
      List<Map<String, dynamic>> pipeline) async {
    // Simple aggregation implementation
    var result = List<Map<String, dynamic>>.from(_documents);
    
    for (final stage in pipeline) {
      if (stage.containsKey('\$match')) {
        final matchQuery = stage['\$match'] as Map<String, dynamic>;
        result = result.where((doc) {
          return matchQuery.entries.every((entry) {
            return doc[entry.key] == entry.value;
          });
        }).toList();
      } else if (stage.containsKey('\$group')) {
        // Basic group implementation
        final groupSpec = stage['\$group'] as Map<String, dynamic>;
        final groupBy = groupSpec['\$groupBy'] as String;
        
        final groups = <dynamic, List<Map<String, dynamic>>>{};
        for (final doc in result) {
          final key = doc[groupBy];
          groups.putIfAbsent(key, () => []).add(doc);
        }
        
        result = groups.entries.map((entry) {
          return {
            '_id': entry.key,
            'count': entry.value.length,
          };
        }).toList();
      }
    }
    
    return result;
  }
}