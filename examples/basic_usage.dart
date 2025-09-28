import 'package:dart_nosql_database/dart_nosql_database.dart';

/// Basic usage examples for the Dart NoSQL Database.
void main() async {
  print('🚀 Dart NoSQL Database - Basic Usage Examples\n');

  // Create a new database instance
  final db = DartNoSQLDatabase(name: 'example_db');

  print('📦 Created database instance: example_db');

  // Example 1: Basic CRUD Operations
  print('\n=== Example 1: Basic CRUD Operations ===');

  // Insert documents
  await db.insert({
    'name': 'Alice Johnson',
    'age': 30,
    'city': 'New York',
    'skills': ['Dart', 'Flutter', 'Firebase'],
    'active': true,
    'salary': 75000.0,
  });

  await db.insert({
    'name': 'Bob Smith',
    'age': 25,
    'city': 'San Francisco',
    'skills': ['JavaScript', 'React', 'Node.js'],
    'active': true,
    'salary': 65000.0,
  });

  await db.insert({
    'name': 'Charlie Brown',
    'age': 35,
    'city': 'Seattle',
    'skills': ['Python', 'Django', 'PostgreSQL'],
    'active': false,
    'salary': 80000.0,
  });

  print('✅ Inserted 3 sample documents');

  // Count documents
  final count = await db.count();
  print('📊 Total documents: $count');

  // Example 2: Simple Queries
  print('\n=== Example 2: Simple Queries ===');

  // Find users older than 25
  final adults = await db.query((doc) => doc['age'] > 25);
  print('👥 Users older than 25: ${adults.length}');
  adults.forEach(
      (user) => print('   - ${user['name']} (${user['age']} years old)'));

  // Find users from specific cities
  final westCoastUsers = await db
      .query((doc) => ['San Francisco', 'Seattle'].contains(doc['city']));
  print('\n🌊 West Coast users: ${westCoastUsers.length}');
  westCoastUsers
      .forEach((user) => print('   - ${user['name']} from ${user['city']}'));

  // Example 3: Complex Queries
  print('\n=== Example 3: Complex Queries ===');

  // Find active users with high salary
  final highEarners =
      await db.query((doc) => doc['active'] == true && doc['salary'] > 70000);
  print('💰 Active high earners: ${highEarners.length}');
  highEarners
      .forEach((user) => print('   - ${user['name']}: \$${user['salary']}'));

  // Find users with specific skills
  final dartDevelopers =
      await db.query((doc) => doc['skills'].contains('Dart'));
  print('\n🎯 Dart developers: ${dartDevelopers.length}');
  dartDevelopers.forEach(
      (dev) => print('   - ${dev['name']}: ${dev['skills'].join(', ')}'));

  // Example 4: Updates
  print('\n=== Example 4: Updates ===');

  // Update Bob's salary
  final updated = await db.update((doc) => doc['name'] == 'Bob Smith',
      {'salary': 70000.0, 'promoted': true});
  print('✏️ Updated $updated user(s)');

  // Verify the update
  final updatedBob = await db.findOne((doc) => doc['name'] == 'Bob Smith');
  print('📈 Bob\'s new salary: \$${updatedBob?['salary']}');

  // Example 5: Array Operations
  print('\n=== Example 5: Array Operations ===');

  // Find users with multiple skills
  final multiSkilled = await db.query((doc) => doc['skills'].length > 2);
  print('🔧 Multi-skilled users: ${multiSkilled.length}');
  multiSkilled.forEach(
      (user) => print('   - ${user['name']}: ${user['skills'].length} skills'));

  // Example 6: Indexing
  print('\n=== Example 6: Indexing ===');

  // Create indexes for better performance
  await db.createIndex('age');
  await db.createIndex('city');
  print('📊 Created indexes on age and city fields');

  // Get index information
  final indexInfo = await db.getIndexInfo();
  print('📈 Index information: $indexInfo');

  // Example 7: Aggregation-like Operations
  print('\n=== Example 7: Aggregation-like Operations ===');

  // Get all users and calculate average age
  final allUsers = await db.findAll();
  final totalAge = allUsers.fold(0, (sum, user) => sum + user['age'] as int);
  final averageAge = totalAge / allUsers.length;
  print('📊 Average age: ${averageAge.toStringAsFixed(1)} years');

  // Group users by city
  final usersByCity = <String, List<Map<String, dynamic>>>{};
  for (final user in allUsers) {
    final city = user['city'] as String;
    usersByCity.putIfAbsent(city, () => []).add(user);
  }

  print('\n🏙️  Users by city:');
  usersByCity
      .forEach((city, users) => print('   - $city: ${users.length} user(s)'));

  // Example 8: Database Statistics
  print('\n=== Example 8: Database Statistics ===');

  final stats = await db.getStats();
  print('📋 Database Statistics:');
  print('   - Name: ${stats['name']}');
  print('   - Documents: ${stats['documentCount']}');
  print('   - Indexes: ${stats['indexes'].length}');

  // Example 9: Find and Modify
  print('\n=== Example 9: Find and Modify ===');

  // Find one user and update them
  final charlie = await db.findOne((doc) => doc['name'] == 'Charlie Brown');
  if (charlie != null) {
    print('🔍 Found Charlie: ${charlie['name']}');

    await db.updateOne((doc) => doc['name'] == 'Charlie Brown',
        {'last_login': DateTime.now().toIso8601String()});

    print('✅ Updated Charlie\'s last login time');
  }

  // Example 10: Cleanup
  print('\n=== Example 10: Cleanup ===');

  // Delete inactive users
  final deleted = await db.delete((doc) => doc['active'] == false);
  print('🗑️  Deleted $deleted inactive user(s)');

  // Final count
  final finalCount = await db.count();
  print('📊 Final document count: $finalCount');

  print('\n✨ Basic usage examples completed!');
}
