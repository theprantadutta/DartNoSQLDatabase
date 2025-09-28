import 'package:test/test.dart';
import 'package:dart_nosql_database/dart_nosql_database.dart';

void main() {
  group('DartNoSQLDatabase', () {
    late DartNoSQLDatabase db;

    setUp(() async {
      db = DartNoSQLDatabase(name: 'test_db');
    });

    tearDown(() async {
      await db.clear();
    });

    group('Basic Operations', () {
      test('should insert a document', () async {
        final doc = {'name': 'Test User', 'age': 25};
        final result = await db.insert(doc);

        expect(result, contains('_id'));
        expect(result['name'], equals('Test User'));
        expect(result['age'], equals(25));
      });

      test('should insert multiple documents', () async {
        final docs = [
          {'name': 'User 1', 'age': 25},
          {'name': 'User 2', 'age': 30},
          {'name': 'User 3', 'age': 35}
        ];

        final results = await db.insertMany(docs);

        expect(results.length, equals(3));
        expect(results[0], contains('_id'));
        expect(results[1], contains('_id'));
        expect(results[2], contains('_id'));
      });

      test('should count documents', () async {
        await db.insert({'name': 'User 1'});
        await db.insert({'name': 'User 2'});
        await db.insert({'name': 'User 3'});

        final count = await db.count();
        expect(count, equals(3));
      });

      test('should find all documents', () async {
        await db.insert({'name': 'User 1'});
        await db.insert({'name': 'User 2'});

        final allDocs = await db.findAll();
        expect(allDocs.length, equals(2));
      });

      test('should clear all documents', () async {
        await db.insert({'name': 'User 1'});
        await db.insert({'name': 'User 2'});
        await db.clear();

        final count = await db.count();
        expect(count, equals(0));
      });
    });

    group('Query Operations', () {
      setUp(() async {
        await db.insertMany([
          {'name': 'Alice', 'age': 30, 'city': 'New York', 'active': true},
          {'name': 'Bob', 'age': 25, 'city': 'San Francisco', 'active': true},
          {'name': 'Charlie', 'age': 35, 'city': 'Seattle', 'active': false},
          {'name': 'Diana', 'age': 28, 'city': 'New York', 'active': true},
        ]);
      });

      test('should query documents with simple condition', () async {
        final results = await db.query((doc) => doc['age'] > 25);

        expect(results.length, equals(3));
        expect(results.every((doc) => doc['age'] > 25), isTrue);
      });

      test('should query documents with equality condition', () async {
        final results = await db.query((doc) => doc['city'] == 'New York');

        expect(results.length, equals(2));
        expect(results.every((doc) => doc['city'] == 'New York'), isTrue);
      });

      test('should query documents with boolean condition', () async {
        final results = await db.query((doc) => doc['active'] == true);

        expect(results.length, equals(3));
        expect(results.every((doc) => doc['active'] == true), isTrue);
      });

      test('should query documents with complex conditions', () async {
        final results = await db.query((doc) =>
            doc['age'] > 25 &&
            doc['active'] == true &&
            doc['city'] == 'New York');

        expect(results.length, equals(2));
        expect(
            results.every((doc) =>
                doc['age'] > 25 &&
                doc['active'] == true &&
                doc['city'] == 'New York'),
            isTrue);
      });

      test('should find one document', () async {
        final result = await db.findOne((doc) => doc['name'] == 'Alice');

        expect(result, isNotNull);
        expect(result!['name'], equals('Alice'));
        expect(result['age'], equals(30));
      });

      test('should return null when findOne finds nothing', () async {
        final result = await db.findOne((doc) => doc['name'] == 'NonExistent');

        expect(result, isNull);
      });
    });

    group('Update Operations', () {
      setUp(() async {
        await db.insertMany([
          {'name': 'Alice', 'age': 30, 'city': 'New York'},
          {'name': 'Bob', 'age': 25, 'city': 'San Francisco'},
          {'name': 'Charlie', 'age': 35, 'city': 'Seattle'},
        ]);
      });

      test('should update multiple documents', () async {
        final updatedCount =
            await db.update((doc) => doc['age'] > 25, {'status': 'senior'});

        expect(updatedCount, equals(2));

        final updatedDocs = await db.query((doc) => doc.containsKey('status'));
        expect(updatedDocs.length, equals(2));
        expect(updatedDocs.every((doc) => doc['status'] == 'senior'), isTrue);
      });

      test('should update one document', () async {
        final updated = await db
            .updateOne((doc) => doc['name'] == 'Alice', {'promoted': true});

        expect(updated, isTrue);

        final alice = await db.findOne((doc) => doc['name'] == 'Alice');
        expect(alice?['promoted'], isTrue);
      });

      test('should return false when updateOne finds nothing', () async {
        final updated = await db.updateOne(
            (doc) => doc['name'] == 'NonExistent', {'promoted': true});

        expect(updated, isFalse);
      });
    });

    group('Delete Operations', () {
      setUp(() async {
        await db.insertMany([
          {'name': 'Alice', 'age': 30, 'active': true},
          {'name': 'Bob', 'age': 25, 'active': true},
          {'name': 'Charlie', 'age': 35, 'active': false},
          {'name': 'Diana', 'age': 28, 'active': false},
        ]);
      });

      test('should delete multiple documents', () async {
        final deletedCount = await db.delete((doc) => doc['active'] == false);

        expect(deletedCount, equals(2));

        final remaining = await db.count();
        expect(remaining, equals(2));

        final allActive = await db.query((doc) => doc['active'] == false);
        expect(allActive.isEmpty, isTrue);
      });

      test('should delete one document', () async {
        final deleted = await db.deleteOne((doc) => doc['name'] == 'Alice');

        expect(deleted, isTrue);

        final alice = await db.findOne((doc) => doc['name'] == 'Alice');
        expect(alice, isNull);
      });

      test('should return false when deleteOne finds nothing', () async {
        final deleted =
            await db.deleteOne((doc) => doc['name'] == 'NonExistent');

        expect(deleted, isFalse);
      });
    });

    group('Array Operations', () {
      setUp(() async {
        await db.insertMany([
          {
            'name': 'Alice',
            'skills': ['Dart', 'Flutter', 'Firebase'],
            'scores': [85, 90, 78]
          },
          {
            'name': 'Bob',
            'skills': ['JavaScript', 'React', 'Node.js'],
            'scores': [92, 88, 95]
          },
          {
            'name': 'Charlie',
            'skills': ['Python', 'Django'],
            'scores': [87, 91]
          },
        ]);
      });

      test('should query array contains', () async {
        final results = await db.query((doc) => doc['skills'].contains('Dart'));

        expect(results.length, equals(1));
        expect(results[0]['name'], equals('Alice'));
      });

      test('should query array length', () async {
        final results = await db.query((doc) => doc['skills'].length > 2);

        expect(results.length, equals(2));
      });

      test('should query array element access', () async {
        final results = await db.query((doc) => doc['scores'][0] > 85);

        expect(results.length, equals(2));
      });
    });

    group('Indexing', () {
      setUp(() async {
        await db.insertMany([
          {'name': 'Alice', 'age': 30, 'city': 'New York'},
          {'name': 'Bob', 'age': 25, 'city': 'San Francisco'},
          {'name': 'Charlie', 'age': 35, 'city': 'Seattle'},
          {'name': 'Diana', 'age': 28, 'city': 'New York'},
        ]);
      });

      test('should create index', () async {
        await db.createIndex('age');

        final indexInfo = await db.getIndexInfo();
        expect(indexInfo.containsKey('age'), isTrue);
      });

      test('should drop index', () async {
        await db.createIndex('age');
        await db.dropIndex('age');

        final indexInfo = await db.getIndexInfo();
        expect(indexInfo.containsKey('age'), isFalse);
      });

      test('should get index info', () async {
        await db.createIndex('age');
        await db.createIndex('city');

        final info = await db.getIndexInfo();
        expect(info.length, equals(2));
        expect(info, contains('age'));
        expect(info, contains('city'));
      });
    });

    group('Statistics', () {
      setUp(() async {
        await db.insertMany([
          {'name': 'Alice', 'age': 30},
          {'name': 'Bob', 'age': 25},
        ]);
        await db.createIndex('age');
      });

      test('should get database stats', () async {
        final stats = await db.getStats();

        expect(stats['name'], equals('test_db'));
        expect(stats['documentCount'], equals(2));
        expect(stats['indexes'], isNotEmpty);
      });
    });

    group('Error Handling', () {
      test('should throw on null insert', () async {
        expect(() => db.insert(null as dynamic), throwsA(isA<Error>()));
      });

      test('should throw on null query predicate', () async {
        expect(() => db.query(null as dynamic), throwsA(isA<Error>()));
      });

      test('should throw on null update predicate', () async {
        expect(() => db.update(null as dynamic, {}), throwsA(isA<Error>()));
      });

      test('should throw on null update data', () async {
        expect(() => db.update((doc) => true, null as dynamic), throwsA(isA<Error>()));
      });

      test('should throw on null delete predicate', () async {
        expect(() => db.delete(null as dynamic), throwsA(isA<Error>()));
      });

      test('should handle errors in query predicate gracefully', () async {
        await db.insert({'name': 'Test'});

        // This should not throw, just return empty results
        final results =
            await db.query((doc) => doc['nonexistent']['nested'] > 10);

        expect(results.isEmpty, isTrue);
      });
    });
  });
}
