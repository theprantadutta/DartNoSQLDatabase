# Dart NoSQL Database

A lightweight, document-based NoSQL database with a native Dart query language. This project provides a simple yet powerful way to store and query Dart Map objects using familiar Dart syntax.

## Features

- **Document-based storage**: Store data as Dart Map objects
- **Native Dart queries**: Use Dart functions as query filters
- **Type-safe operations**: Leverage Dart's type system
- **Simple API**: Intuitive methods for CRUD operations
- **In-memory and persistent storage options
- **Query optimization**: Efficient query execution with indexing support

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  dart_nosql_database:
    git: https://github.com/theprantadutta/dart-nosql-database.git
```

## Quick Start

```dart
import 'package:dart_nosql_database/dart_nosql_database.dart';

void main() async {
  // Create a new database instance
  final db = DartNoSQLDatabase();
  
  // Insert documents
  await db.insert({
    'name': 'Alice',
    'age': 30,
    'city': 'New York',
    'skills': ['Dart', 'Flutter', 'Firebase']
  });
  
  await db.insert({
    'name': 'Bob',
    'age': 25,
    'city': 'San Francisco',
    'skills': ['JavaScript', 'React', 'Node.js']
  });
  
  // Query with Dart functions
  final results = await db.query((Map doc) => 
    doc['age'] > 25 && doc['name'].startsWith('A')
  );
  
  print(results); // [{name: Alice, age: 30, ...}]
}
```

## Query Language

The database uses Dart functions as queries. This means you can use all Dart language features in your queries:

### Basic Queries

```dart
// Find users older than 25
final adults = await db.query((doc) => doc['age'] > 25);

// Find users with specific name
final alice = await db.query((doc) => doc['name'] == 'Alice');

// Find users in specific cities
final sfUsers = await db.query((doc) => 
  ['San Francisco', 'Los Angeles'].contains(doc['city'])
);
```

### Complex Queries

```dart
// Combine multiple conditions
final complex = await db.query((doc) => 
  doc['age'] >= 18 && 
  doc['age'] <= 65 && 
  doc['skills'].contains('Dart') &&
  doc['name'].toLowerCase().startsWith('a')
);

// Nested object queries
final nested = await db.query((doc) => 
  doc['address']['city'] == 'New York' &&
  doc['address']['zipCode'] > 10000
);
```

### Array Operations

```dart
// Find documents with array containing specific value
final dartDevs = await db.query((doc) => 
  doc['skills'].contains('Dart')
);

// Find documents with array length condition
final multiSkilled = await db.query((doc) => 
  doc['skills'].length > 3
);

// Find documents with specific array element
final firstSkill = await db.query((doc) => 
  doc['skills'][0] == 'Dart'
);
```

## API Reference

### Database Class

#### `DartNoSQLDatabase()`
Creates a new database instance.

#### `Future<void> insert(Map<String, dynamic> document)`
Inserts a document into the database.

#### `Future<List<Map<String, dynamic>>> query(bool Function(Map) predicate)`
Queries documents using a Dart function predicate.

#### `Future<void> update(bool Function(Map) predicate, Map<String, dynamic> updateData)`
Updates documents matching the predicate.

#### `Future<void> delete(bool Function(Map) predicate)`
Deletes documents matching the predicate.

#### `Future<void> clear()`
Clears all documents from the database.

#### `Future<int> count([bool Function(Map)? predicate])`
Counts documents, optionally matching a predicate.

### Advanced Features

#### Indexing

```dart
// Create an index on a field
await db.createIndex('age');
await db.createIndex('name');

// Queries will automatically use indexes when beneficial
final results = await db.query((doc) => doc['age'] > 25);
```

#### Persistence

```dart
// Save database to file
await db.saveToFile('my_database.json');

// Load database from file
await db.loadFromFile('my_database.json');
```

## Examples

See the `examples/` directory for more comprehensive usage examples:

- Basic CRUD operations
- Complex queries
- Index usage
- Performance benchmarks

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Roadmap

- [ ] Query optimization and execution planning
- [ ] Compound indexes
- [ ] Aggregation pipeline support
- [ ] Replication and clustering
- [ ] Web-based admin interface
- [ ] REST API server