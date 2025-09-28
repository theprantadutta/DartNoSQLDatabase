import 'dart:async';
import 'dart:collection';

/// Manages indexes for efficient query execution.
class IndexManager {
  final Map<String, Map<dynamic, Set<int>>> _indexes;
  final Map<String, String> _indexTypes;
  
  IndexManager()
      : _indexes = {},
        _indexTypes = {};

  /// Creates an index on a field.
  /// 
  /// [field] - The field name to index.
  /// [documents] - The documents to build the index from.
  Future<void> createIndex(String field, List<Map<String, dynamic>> documents) 
      async {
    if (field.isEmpty) {
      throw ArgumentError('Field name cannot be empty');
    }

    // Create the index structure
    _indexes[field] = <dynamic, Set<int>>{};
    _indexTypes[field] = 'btree'; // Default to B-tree index
    
    // Build the index from existing documents
    for (int i = 0; i < documents.length; i++) {
      final doc = documents[i];
      final value = _getFieldValue(doc, field);
      
      if (value != null) {
        if (!_indexes[field]!.containsKey(value)) {
          _indexes[field]![value] = <int>{};
        }
        _indexes[field]![value]!.add(i);
      }
    }
  }

  /// Drops an index on a field.
  /// 
  /// [field] - The field name to remove the index from.
  Future<void> dropIndex(String field) async {
    _indexes.remove(field);
    _indexTypes.remove(field);
  }

  /// Adds a document to all relevant indexes.
  /// 
  /// [document] - The document to add to indexes.
  Future<void> addToIndexes(Map<String, dynamic> document) async {
    final docId = document['_id'] ?? document.hashCode;
    
    for (final field in _indexes.keys) {
      final value = _getFieldValue(document, field);
      
      if (value != null) {
        if (!_indexes[field]!.containsKey(value)) {
          _indexes[field]![value] = <int>{};
        }
        _indexes[field]![value]!.add(docId);
      }
    }
  }

  /// Removes a document from all relevant indexes.
  /// 
  /// [document] - The document to remove from indexes.
  Future<void> removeFromIndexes(Map<String, dynamic> document) async {
    final docId = document['_id'] ?? document.hashCode;
    
    for (final field in _indexes.keys) {
      final value = _getFieldValue(document, field);
      
      if (value != null && _indexes[field]!.containsKey(value)) {
        _indexes[field]![value]!.remove(docId);
        
        // Clean up empty value sets
        if (_indexes[field]![value]!.isEmpty) {
          _indexes[field]!.remove(value);
        }
      }
    }
  }

  /// Updates a document in all relevant indexes.
  /// 
  /// [oldDocument] - The old version of the document.
  /// [newDocument] - The new version of the document.
  Future<void> updateInIndexes(
      Map<String, dynamic> oldDocument,
      Map<String, dynamic> newDocument) async {
    
    await removeFromIndexes(oldDocument);
    await addToIndexes(newDocument);
  }

  /// Queries an index for documents matching a value.
  /// 
  /// [field] - The indexed field to query.
  /// [value] - The value to match.
  /// Returns a list of document IDs that match the value.
  List<int>? queryIndex(String field, dynamic value) {
    if (!_indexes.containsKey(field)) {
      return null; // No index on this field
    }
    
    return _indexes[field]![value]?.toList();
  }

  /// Queries an index for documents within a range.
  /// 
  /// [field] - The indexed field to query.
  /// [minValue] - The minimum value (inclusive).
  /// [maxValue] - The maximum value (inclusive).
  /// Returns a list of document IDs within the range.
  List<int>? queryIndexRange(
      String field, dynamic minValue, dynamic maxValue) {
    
    if (!_indexes.containsKey(field)) {
      return null; // No index on this field
    }
    
    final results = <int>[];
    final index = _indexes[field]!;
    
    for (final entry in index.entries) {
      if (_isInRange(entry.key, minValue, maxValue)) {
        results.addAll(entry.value);
      }
    }
    
    return results;
  }

  /// Checks if a field has an index.
  /// 
  /// [field] - The field name to check.
  /// Returns true if the field is indexed.
  bool hasIndex(String field) {
    return _indexes.containsKey(field);
  }

  /// Gets information about all indexes.
  /// 
  /// Returns a map containing index information.
  Map<String, dynamic> getIndexInfo() {
    final info = <String, dynamic>{};
    
    for (final field in _indexes.keys) {
      info[field] = {
        'type': _indexTypes[field],
        'keys_count': _indexes[field]!.length,
        'is_unique': false, // Could be enhanced to support unique indexes
      };
    }
    
    return info;
  }

  /// Clears all indexes.
  Future<void> clearAllIndexes() async {
    _indexes.clear();
    _indexTypes.clear();
  }

  /// Gets the value of a field from a document, supporting nested fields.
  /// 
  /// [document] - The document to extract the field from.
  /// [field] - The field name, can be nested (e.g., 'address.city').
  /// Returns the field value, or null if not found.
  dynamic _getFieldValue(Map<String, dynamic> document, String field) {
    if (field.contains('.')) {
      // Handle nested fields
      final parts = field.split('.');
      dynamic current = document;
      
      for (final part in parts) {
        if (current is Map<String, dynamic> && current.containsKey(part)) {
          current = current[part];
        } else {
          return null;
        }
      }
      
      return current;
    } else {
      // Handle top-level fields
      return document[field];
    }
  }

  /// Checks if a value is within a specified range.
  /// 
  /// [value] - The value to check.
  /// [minValue] - The minimum value.
  /// [maxValue] - The maximum value.
  /// Returns true if the value is in range.
  bool _isInRange(dynamic value, dynamic minValue, dynamic maxValue) {
    if (value == null) return false;
    
    try {
      if (value is Comparable) {
        return (value.compareTo(minValue) >= 0) && 
               (value.compareTo(maxValue) <= 0);
      }
    } catch (e) {
      // If comparison fails, assume not in range
    }
    
    return false;
  }

  /// Rebuilds all indexes from the current documents.
  /// 
  /// [documents] - The current list of documents.
  Future<void> rebuildAllIndexes(List<Map<String, dynamic>> documents) async {
    final indexFields = List<String>.from(_indexes.keys);
    
    // Clear existing indexes
    _indexes.clear();
    _indexTypes.clear();
    
    // Recreate indexes
    for (final field in indexFields) {
      await createIndex(field, documents);
    }
  }

  /// Gets index usage statistics.
  /// 
  /// Returns statistics about index usage and effectiveness.
  Map<String, dynamic> getIndexStats() {
    final stats = <String, dynamic>{
      'total_indexes': _indexes.length,
      'indexed_fields': _indexes.keys.toList(),
      'index_details': {},
    };
    
    for (final field in _indexes.keys) {
      stats['index_details'][field] = {
        'keys_count': _indexes[field]!.length,
        'type': _indexTypes[field],
        'memory_usage': 'estimated', // Could be enhanced with actual memory usage
      };
    }
    
    return stats;
  }
}