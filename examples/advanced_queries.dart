import 'package:dart_nosql_database/dart_nosql_database.dart';

/// Advanced query examples for the Dart NoSQL Database.
void main() async {
  print('🚀 Dart NoSQL Database - Advanced Query Examples\n');

  final db = DartNoSQLDatabase(name: 'advanced_queries');

  // Insert sample data with more complex structure
  await db.insertMany([
    {
      'name': 'Alice Johnson',
      'age': 30,
      'email': 'alice@example.com',
      'address': {
        'street': '123 Main St',
        'city': 'New York',
        'zipCode': '10001',
        'country': 'USA'
      },
      'skills': [
        {'name': 'Dart', 'level': 'expert', 'years': 5},
        {'name': 'Flutter', 'level': 'advanced', 'years': 4},
        {'name': 'Firebase', 'level': 'intermediate', 'years': 2}
      ],
      'projects': [
        {'name': 'E-commerce App', 'status': 'completed', 'budget': 50000},
        {
          'name': 'Social Media Platform',
          'status': 'in_progress',
          'budget': 75000
        }
      ],
      'active': true,
      'joinDate': DateTime(2020, 1, 15).toIso8601String()
    },
    {
      'name': 'Bob Smith',
      'age': 25,
      'email': 'bob@example.com',
      'address': {
        'street': '456 Market St',
        'city': 'San Francisco',
        'zipCode': '94105',
        'country': 'USA'
      },
      'skills': [
        {'name': 'JavaScript', 'level': 'expert', 'years': 6},
        {'name': 'React', 'level': 'advanced', 'years': 4},
        {'name': 'Node.js', 'level': 'advanced', 'years': 3}
      ],
      'projects': [
        {'name': 'Dashboard App', 'status': 'completed', 'budget': 30000}
      ],
      'active': true,
      'joinDate': DateTime(2021, 3, 10).toIso8601String()
    },
    {
      'name': 'Charlie Brown',
      'age': 35,
      'email': 'charlie@example.com',
      'address': {
        'street': '789 Pine St',
        'city': 'Seattle',
        'zipCode': '98101',
        'country': 'USA'
      },
      'skills': [
        {'name': 'Python', 'level': 'expert', 'years': 8},
        {'name': 'Django', 'level': 'expert', 'years': 6},
        {'name': 'PostgreSQL', 'level': 'advanced', 'years': 5}
      ],
      'projects': [
        {
          'name': 'Data Analytics Platform',
          'status': 'completed',
          'budget': 100000
        },
        {
          'name': 'Machine Learning Service',
          'status': 'in_progress',
          'budget': 150000
        }
      ],
      'active': false,
      'joinDate': DateTime(2019, 6, 20).toIso8601String()
    },
    {
      'name': 'Diana Prince',
      'age': 28,
      'email': 'diana@example.com',
      'address': {
        'street': '321 Oak Ave',
        'city': 'Los Angeles',
        'zipCode': '90210',
        'country': 'USA'
      },
      'skills': [
        {'name': 'Java', 'level': 'advanced', 'years': 4},
        {'name': 'Spring Boot', 'level': 'intermediate', 'years': 2},
        {'name': 'MySQL', 'level': 'advanced', 'years': 3}
      ],
      'projects': [
        {'name': 'Banking System', 'status': 'completed', 'budget': 200000},
        {'name': 'Mobile Banking App', 'status': 'planning', 'budget': 80000}
      ],
      'active': true,
      'joinDate': DateTime(2020, 9, 5).toIso8601String()
    }
  ]);

  print('📦 Inserted 4 sample documents with complex structure');

  // Example 1: Nested Object Queries
  print('\n=== Example 1: Nested Object Queries ===');

  // Find users in specific cities
  final nyUsers = await db.query((doc) => doc['address']['city'] == 'New York');
  print('🏙️  Users in New York: ${nyUsers.length}');
  nyUsers.forEach((user) => print('   - ${user['name']}'));

  // Find users in specific zip code range
  final zipRangeUsers = await db.query((doc) {
    final zip = int.tryParse(doc['address']['zipCode'] ?? '0') ?? 0;
    return zip >= 94100 && zip <= 94200;
  });
  print('\n📮 Users in SF zip code range: ${zipRangeUsers.length}');
  zipRangeUsers.forEach(
      (user) => print('   - ${user['name']} (${user['address']['zipCode']})'));

  // Example 2: Array of Objects Queries
  print('\n=== Example 2: Array of Objects Queries ===');

  // Find users with specific skill level
  final expertDartDevs = await db.query((doc) => doc['skills']
      .any((skill) => skill['name'] == 'Dart' && skill['level'] == 'expert'));
  print('🎯 Expert Dart developers: ${expertDartDevs.length}');
  expertDartDevs.forEach((dev) => print('   - ${dev['name']}'));

  // Find users with high-value projects
  final highValueProjects = await db.query(
      (doc) => doc['projects'].any((project) => project['budget'] > 100000));
  print('\n💰 Users with high-value projects: ${highValueProjects.length}');
  highValueProjects.forEach((user) => print('   - ${user['name']}'));

  // Example 3: Complex Conditional Logic
  print('\n=== Example 3: Complex Conditional Logic ===');

  // Find experienced developers in specific locations
  final experiencedDevs = await db.query((doc) {
    final hasExpertSkill = doc['skills']
        .any((skill) => skill['level'] == 'expert' && skill['years'] >= 5);
    final inTechCity =
        ['San Francisco', 'Seattle'].contains(doc['address']['city']);
    return hasExpertSkill && inTechCity && doc['active'] == true;
  });
  print('🚀 Experienced devs in tech cities: ${experiencedDevs.length}');
  experiencedDevs.forEach((dev) => print('   - ${dev['name']}'));

  // Find users with specific project patterns
  final activeProjectLeaders = await db.query((doc) {
    final completedProjects =
        doc['projects'].where((p) => p['status'] == 'completed').length;
    final inProgressProjects =
        doc['projects'].where((p) => p['status'] == 'in_progress').length;
    return completedProjects >= 1 &&
        inProgressProjects >= 1 &&
        doc['active'] == true;
  });
  print('\n📊 Active project leaders: ${activeProjectLeaders.length}');
  activeProjectLeaders.forEach((user) => print('   - ${user['name']}'));

  // Example 4: Date-based Queries
  print('\n=== Example 4: Date-based Queries ===');

  // Find users who joined after specific date
  final recentJoiners = await db.query((doc) {
    final joinDate = DateTime.parse(doc['joinDate']);
    return joinDate.isAfter(DateTime(2020, 1, 1));
  });
  print('📅 Recent joiners (after 2020): ${recentJoiners.length}');
  recentJoiners.forEach(
      (user) => print('   - ${user['name']} joined ${user['joinDate']}'));

  // Example 5: String Pattern Matching
  print('\n=== Example 5: String Pattern Matching ===');

  // Find users with email domains
  final gmailUsers =
      await db.query((doc) => doc['email'].endsWith('@example.com'));
  print('📧 Users with @example.com emails: ${gmailUsers.length}');

  // Find users with names starting with specific letters
  final aToCUsers = await db.query((doc) {
    final firstLetter = doc['name'][0].toUpperCase();
    return ['A', 'B', 'C'].contains(firstLetter);
  });
  print('\n🔤 Users with names A-C: ${aToCUsers.length}');
  aToCUsers.forEach((user) => print('   - ${user['name']}'));

  // Example 6: Mathematical Operations
  print('\n=== Example 6: Mathematical Operations ===');

  // Find users with average project budget above threshold
  final highBudgetUsers = await db.query((doc) {
    final totalBudget =
        doc['projects'].fold(0, (sum, p) => sum + (p['budget'] as int));
    final avgBudget = totalBudget / doc['projects'].length;
    return avgBudget > 50000;
  });
  print('💼 Users with high average project budget: ${highBudgetUsers.length}');
  highBudgetUsers.forEach((user) {
    final avg =
        user['projects'].fold(0, (sum, p) => sum + (p['budget'] as int)) /
            user['projects'].length;
    print('   - ${user['name']}: \$${avg.toStringAsFixed(0)} avg budget');
  });

  // Example 7: Aggregation-like Queries
  print('\n=== Example 7: Aggregation-like Queries ===');

  // Get all unique skills
  final allUsers = await db.findAll();
  final allSkills = <String>{};
  for (final user in allUsers) {
    for (final skill in user['skills']) {
      allSkills.add(skill['name']);
    }
  }
  print('🛠️  All unique skills in database: ${allSkills.length}');
  allSkills.toList()
    ..sort()
    ..forEach((skill) => print('   - $skill'));

  // Find most common skill levels
  const skillLevels = <String, int>{};
  for (final user in allUsers) {
    for (final skill in user['skills']) {
      final level = skill['level'];
      skillLevels[level] = (skillLevels[level] ?? 0) + 1;
    }
  }
  print('\n📊 Skill level distribution:');
  skillLevels.forEach((level, count) => print('   - $level: $count skills'));

  // Example 8: Complex Updates
  print('\n=== Example 8: Complex Updates ===');

  // Update all active users with a new field
  final updated = await db.update((doc) => doc['active'] == true,
      {'last_activity': DateTime.now().toIso8601String()});
  print('🔄 Updated $updated active users with last activity timestamp');

  // Verify updates
  final activeUsers = await db.query((doc) => doc['active'] == true);
  print('📋 Active users with new field:');
  activeUsers.forEach(
      (user) => print('   - ${user['name']}: ${user['last_activity']}'));

  // Example 9: Benchmark Queries
  print('\n=== Example 9: Query Performance ===');

  // Create indexes for better performance
  await db.createIndex('age');
  await db.createIndex('address.city');
  print('⚡ Created performance indexes');

  // Test query performance
  final stopwatch = Stopwatch()..start();
  final ageQuery = await db.query((doc) => doc['age'] > 25);
  stopwatch.stop();
  print(
      '⏱️  Age query executed in ${stopwatch.elapsedMilliseconds}ms, found ${ageQuery.length} results');

  // Example 10: Export Data
  print('\n=== Example 10: Data Export ===');

  // Export to different formats
  await db.saveToFile('/tmp/advanced_example');
  print('💾 Database saved to /tmp/advanced_example.ddb');

  print('\n✨ Advanced query examples completed!');
}
